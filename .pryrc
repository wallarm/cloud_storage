# frozen_string_literal: true

Pry.config.history_file = "#{File.dirname(__FILE__)}/.irb-save-history"

require 'cloud_storage'
require 'cloud_storage/wrappers/gcs'
require 'cloud_storage/wrappers/s3'

require_relative 'spec/rspec_helpers/gcs'
require_relative 'spec/rspec_helpers/s3'

# rubocop:disable Style/MixinUsage
include RSpecHelpers::Gcs
include RSpecHelpers::S3
# rubocop:enable Style/MixinUsage
