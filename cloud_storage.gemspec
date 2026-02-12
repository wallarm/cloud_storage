# frozen_string_literal: true

require_relative 'lib/cloud_storage/version'

Gem::Specification.new do |spec|
  spec.name          = 'cloud_storage'
  spec.version       = CloudStorage::VERSION
  spec.authors       = ['Maxim Tretyakov']
  spec.email         = ['max@tretyakov-ma.ru']

  spec.summary       = 'CloudStorage'
  spec.description   = 'CloudStorage'
  spec.homepage      = 'https://github.com/wallarm/cloud_storage'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/wallarm/cloud_storage'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
end
