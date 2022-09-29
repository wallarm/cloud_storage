# frozen_string_literal: true

RSpec.describe CloudStorage::Objects::S3 do
  let(:cli) { s3_new_client }
  let(:file) { File.open('spec/fixtures/test.txt', 'rb') }
  let!(:obj) { cli.upload_file(key: 'test_1.txt', file: file) }

  after { file.close }

  describe '#signed_url' do
    subject(:url) { obj.signed_url(expires_in: 30) }

    after { obj.delete! }

    it do
      expect(url).to match(%r{\A#{ENV.fetch('S3_ENDPOINT')}/#{ENV.fetch('S3_BUCKET')}/test_1.txt})
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
        expect { obj.delete! }.not_to(change { cli.exist?('test_1.txt') })
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

    context 'when download to a string io' do
      subject(:content) { obj.download(StringIO.new).read }

      it do
        expect { content }.not_to(change { opened_tmp_files_count })

        expect(content).to eq("This is a test upload\n")
      end

      context 'when 6mb file' do
        let(:file) { File.open('spec/fixtures/6mb.bin', 'rb') }

        it do
          expect { content }.not_to(change { opened_tmp_files_count })

          expect(content.size).to eq(6_000_000)
        end
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

      context 'when 6mb file' do
        let(:file) { File.open('spec/fixtures/6mb.bin', 'rb') }

        it do
          tmp

          expect { content }
            .to change(tmp, :size)
            .from(0)
            .to(6_000_000)
            .and change { opened_tmp_files_count }.by(0)
        end
      end
    end
  end
end
