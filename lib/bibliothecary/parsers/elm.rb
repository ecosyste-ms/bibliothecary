# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    class Elm
      include Bibliothecary::Analyser

      def self.file_patterns
        ["elm-package.json", "elm_dependencies.json", "elm-stuff/exact-dependencies.json"]
      end

      def self.mapping
        {
          match_filenames("elm-package.json", "elm_dependencies.json") => {
            kind: "manifest",
            parser: :parse_json_runtime_manifest,
          },
          match_filename("elm-stuff/exact-dependencies.json") => {
            kind: "lockfile",
            parser: :parse_json_lock,
          },
        }
      end

      def self.parse_json_runtime_manifest(file_contents, options: {})
        manifest = JSON.parse(file_contents)
        dependencies = manifest.fetch("dependencies", {}).map do |name, requirement|
          Dependency.new(
            name: name,
            requirement: requirement,
            type: "runtime",
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_json_lock(file_contents, options: {})
        manifest = JSON.parse file_contents
        dependencies = manifest.map do |name, requirement|
          Dependency.new(
            name: name,
            requirement: requirement,
            type: "runtime",
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end
        ParserResult.new(dependencies: dependencies)
      end
    end
  end
end
