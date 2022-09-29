# frozen_string_literal: true

module CloudStorage
  module Objects
    class Gcs < Base
      def initialize(internal, uri:)
        super internal
        @uri = uri
      end

      def key
        @internal.name
      end

      def signed_url(**opts)
        opts[:expires] = opts.delete(:expires_in)

        if @uri
          opts[:scheme] = @uri.scheme
          opts[:bucket_bound_hostname] = @uri.to_s.gsub(%r{\A#{@uri.scheme}://}, '')
        end

        @internal.signed_url version: :v4, **opts
      end

      alias name key

      def delete!
        @internal.delete
        nil
      end

      private

      def internal_download(local_file)
        @internal.download(local_file)
      end
    end
  end
end
