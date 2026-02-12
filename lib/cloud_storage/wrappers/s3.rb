# frozen_string_literal: true

require 'aws-sdk-s3'
require 'cloud_storage/objects/s3'

module CloudStorage
  module Wrappers
    class S3 < Base
      def initialize(opts = {})
        super
        options = opts.dup

        @bucket_name = options.delete(:bucket)
        @options = options
      end

      class Files
        include Enumerable

        def initialize(client, resource, bucket_name, **opts)
          @client = client
          @resource = resource
          @bucket_name = bucket_name
          @opts = opts
        end

        def each
          return to_enum unless block_given?

          @client.list_objects(bucket: @bucket_name, **@opts).contents.each do |item|
            yield Objects::S3.new \
              item,
              bucket_name: @bucket_name,
              resource: @resource,
              client: @client
          end
        rescue Aws::S3::Errors::NoSuchBucket, Aws::S3::Errors::NotFound, Aws::S3::Errors::InvalidBucketName
        end
      end

      def files(**opts)
        Files.new(client, resource, @bucket_name, **opts)
      end

      def exist?(key)
        resource.bucket(@bucket_name).object(key).exists?
      rescue Aws::S3::Errors::NoSuchBucket, Aws::S3::Errors::NotFound,
        Aws::S3::Errors::InvalidBucketName, Aws::S3::Errors::BadRequest
        false
      end

      def upload_file(key:, file:, **opts)
        return unless upload_file_or_io(key, file, **opts)

        obj = resource.bucket(@bucket_name).object(key)

        Objects::S3.new \
          obj,
          bucket_name: @bucket_name,
          resource: resource,
          client: client
      rescue Aws::S3::Errors::NoSuchBucket, Aws::S3::Errors::NotFound, Aws::S3::Errors::InvalidBucketName
        raise ObjectNotFound, @bucket_name
      end

      def find(key)
        obj = resource.bucket(@bucket_name).object(key)

        raise ObjectNotFound, key unless obj.exists?

        Objects::S3.new \
          obj,
          bucket_name: @bucket_name,
          resource: resource,
          client: client
      rescue Aws::S3::Errors::NoSuchBucket, Aws::S3::Errors::NotFound,
        Aws::S3::Errors::InvalidBucketName, Aws::S3::Errors::BadRequest
        raise ObjectNotFound, key
      end

      def delete_files(keys)
        resource
          .bucket(@bucket_name)
          .delete_objects \
            delete: {
              objects: keys.map { |key| { key: key } },
              quiet: true
            }
      rescue Aws::S3::Errors::NoSuchBucket, Aws::S3::Errors::NotFound, Aws::S3::Errors::InvalidBucketName
      end

      private

      def client
        @client ||= Aws::S3::Client.new(@options)
      end

      def resource
        @resource ||= Aws::S3::Resource.new(@options)
      end

      def transfer_manager
        @transfer_manager ||= Aws::S3::TransferManager.new(client: client)
      end

      def upload_file_or_io(key, file_or_io, **opts)
        if file_or_io.respond_to?(:path)
          transfer_manager.upload_file(file_or_io.path, bucket: @bucket_name, key: key, **opts)
        else
          transfer_manager.upload_stream(bucket: @bucket_name, key: key, **opts) do |write_stream|
            IO.copy_stream(file_or_io, write_stream)
          end
        end
      end
    end
  end
end
