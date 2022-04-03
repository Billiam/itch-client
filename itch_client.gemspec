# frozen_string_literal: true

require_relative "lib/itch/version"

Gem::Specification.new do |spec|
  spec.name          = "itch_client"
  spec.version       = Itch::VERSION
  spec.authors       = ["Billiam"]
  spec.email         = ["billiamthesecond@gmail.com"]

  spec.summary       = "Itch.io screen scraping utility"
  spec.homepage      = "https://github.com/Billiam/itch-client"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mechanize", "~> 2.8"
end
