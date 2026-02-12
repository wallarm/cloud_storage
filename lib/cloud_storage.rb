# frozen_string_literal: true

require_relative 'cloud_storage/version'

require_relative 'cloud_storage/wrappers/base'
require_relative 'cloud_storage/objects/base'

module CloudStorage
  class ObjectNotFound < StandardError
  end

  class << self
    def register_wrapper(klass)
      raise "#{klass.name} should be subclass of #{Wrappers::Base}" unless klass < Wrappers::Base

      @wrappers ||= {}

      id = klass.name.gsub(/\A.+::/, '').downcase.to_sym
      raise "wrapper already registered: #{id}" if @wrappers.key?(id)

      @wrappers[id] = klass
    end

    def [](value)
      @wrappers[value] if @wrappers
    end
  end

  class Client
    attr_reader :type

    def initialize(type, opts = {})
      @type = type.to_sym

      raise "wrapper is not registered for type \"#{type}\"" if (klass = CloudStorage[@type]).nil?

      @wrapper = klass.new(opts)
    end

    def files(**opts)
      @wrapper.files(**opts)
    end

    def exist?(key)
      @wrapper.exist?(key)
    end

    def upload_file(key:, file:, **opts)
      @wrapper.upload_file(key: key, file: file, **opts)
    end

    def find(key)
      @wrapper.find(key)
    end

    def delete_files(keys)
      @wrapper.delete_files(keys)
    end
  end
end
