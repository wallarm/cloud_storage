# frozen_string_literal: true

module CloudStorage
  module Objects
    class S3 < Base
      attr_reader :bucket_name

      def initialize(internal, resource:, client:, bucket_name:)
        super internal

        @bucket_name = bucket_name
        @resource = resource
        @client = client
      end

      def key
        @internal.key
      end

      def signed_url(**opts)
        signer = Aws::S3::Presigner.new(client: @client)

        signer.presigned_url \
          :get_object,
          bucket: bucket_name,
          key: key,
          expires_in: opts[:expires_in],
          response_content_type: opts[:content_type]
      end

      alias name key

      def delete!
        @resource.bucket(bucket_name).object(key).delete
        nil
      end

      private

      def internal_download(local_file)
        @client.get_object(response_target: local_file, bucket: bucket_name, key: key)

        local_file
      end
    end
  end
end
