# frozen_string_literal: true

RSpec.describe CloudStorage::Objects::Gcs do
  let(:cli) { gcs_new_client }
  let(:file) { File.open('spec/fixtures/test.txt', 'rb') }
  let!(:obj) { cli.upload_file(key: 'test_1.txt', file: file) }

  after { file.close }

  describe '#signed_url' do
    after { obj.delete! }

    # we cannot sign url for anonymous without a key
    let(:key) { OpenSSL::PKey::RSA.new(File.read('spec/fixtures/dummy.key')) }

    context 'when without options' do
      subject(:url) { obj.signed_url(expires_in: 30, issuer: 'max@tretyakov-ma.ru', signing_key: key) }

      it { is_expected.to match(%r{\A#{ENV.fetch('GCS_ENDPOINT')}#{ENV.fetch('GCS_BUCKET')}/test_1.txt}) }
    end

    context 'when with some internal options' do
      subject(:url) { obj.signed_url(expires_in: 30, issuer: 'max@tretyakov-ma.ru', signing_key: key, version: :v2) }

      it { is_expected.to match(%r{\Ahttps://storage.googleapis.com/#{ENV.fetch('GCS_BUCKET')}/test_1.txt}) }
    end
  end

  describe '#delete!' do
    context 'when file exists' do
      it do
        expect { obj.delete! }
          .to change { cli.exist?('test_1.txt') }.from(true).to(false)
      end
    end

    context 'when file does not exist' do
      before { obj.delete! }

      it do
        expect { obj.delete! }.to raise_error(Google::Cloud::NotFoundError)
      end
    end
  end

  describe '#download' do
    after { obj.delete! }

    context 'when default' do
      subject(:content) { tmp.read }

      let(:tmp) { obj.download }

      after do
        tmp.close
        tmp.unlink
      end

      it do
        expect { content }.to change { opened_tmp_files_count }.by(1)

        expect(content).to eq("This is a test upload\n")
      end
    end

    context 'when download to a custom tmp' do
      subject(:content) { obj.download(tmp) }

      let(:tmp) { Tempfile.new }

      after do
        tmp.close
        tmp.unlink
      end

      it do
        tmp

        expect { content }
          .to change(tmp, :read)
          .from('')
          .to("This is a test upload\n")
          .and change { opened_tmp_files_count }.by(0)
      end
    end

    context 'when download to a string io' do
      subject(:content) { obj.download(StringIO.new).read }

      it do
        expect { content }.not_to(change { opened_tmp_files_count })

        expect(content).to eq("This is a test upload\n")
      end
    end
  end
end
