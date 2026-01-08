# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :readme do
  desc "Update the supported file formats list in README.md"
  task :update do
    require "bibliothecary"

    display_names = {
      "actions" => "Actions",
      "bentoml" => "BentoML",
      "bower" => "Bower",
      "cargo" => "Cargo",
      "carthage" => "Carthage",
      "clojars" => "Clojars",
      "cocoapods" => "CocoaPods",
      "cog" => "Cog",
      "conan" => "Conan",
      "conda" => "Anaconda",
      "cpan" => "CPAN",
      "cran" => "CRAN",
      "deno" => "Deno",
      "docker" => "Docker",
      "dub" => "Dub",
      "dvc" => "DVC",
      "elm" => "Elm",
      "go" => "Go",
      "hackage" => "Hackage",
      "haxelib" => "Haxelib",
      "hex" => "Hex",
      "homebrew" => "Homebrew",
      "julia" => "Julia",
      "luarocks" => "LuaRocks",
      "maven" => "Maven",
      "meteor" => "Meteor",
      "mlflow" => "MLflow",
      "nimble" => "Nimble",
      "npm" => "npm",
      "nuget" => "Nuget",
      "ollama" => "Ollama",
      "packagist" => "Packagist",
      "pub" => "Pub",
      "pypi" => "PyPi",
      "rubygems" => "RubyGems",
      "shard" => "Shards",
      "swiftpm" => "Swift",
      "vcpkg" => "Vcpkg",
    }

    supported = Bibliothecary.supported_files
    lines = []

    supported.sort_by { |k, _| display_names.fetch(k, k).downcase }.each do |platform, patterns|
      name = display_names.fetch(platform, platform.capitalize)
      lines << "- #{name}"
      patterns.each do |pattern|
        escaped = pattern.gsub("*", "\\*")
        lines << "  - #{escaped}"
      end
    end

    readme_path = File.expand_path("README.md", __dir__)
    content = File.read(readme_path)

    start_marker = "## Supported package manager file formats\n"
    end_marker = "\n## Development"

    start_idx = content.index(start_marker)
    end_idx = content.index(end_marker)

    unless start_idx && end_idx
      abort "Could not find markers in README.md"
    end

    new_section = "#{start_marker}\n#{lines.join("\n")}\n"
    new_content = content[0...start_idx] + new_section + content[end_idx..]

    File.write(readme_path, new_content)
    puts "Updated README.md with #{supported.size} package managers"
  end
end