# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bibliothecary/version"

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= 3.4.0"

  spec.name          = "ecosystems-bibliothecary"
  spec.version       = Bibliothecary::VERSION
  spec.authors       = ["Andrew Nesbitt"]
  spec.email         = ["andrewnez@gmail.com"]

  spec.summary       = "Find and parse manifests"
  spec.homepage      = "https://github.com/ecosyste-ms/bibliothecary"
  spec.license       = "AGPL-3.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|\.github)/|^bin/(benchmark|console|setup)|^\.|^(Gemfile|Rakefile|CODE_OF_CONDUCT)})
  end
  spec.bindir        = "bin"
  spec.executables   = %w[bibliothecary]
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler"
  spec.add_dependency "csv"
  spec.add_dependency "json", "~> 2.8"
  spec.add_dependency "ox", ">= 2.8.1"
  spec.add_dependency "racc" # required by tomlrb but not declared as a dependency
  spec.add_dependency "tomlrb", "~> 2.0"

  spec.metadata["rubygems_mfa_required"] = "true"
end
