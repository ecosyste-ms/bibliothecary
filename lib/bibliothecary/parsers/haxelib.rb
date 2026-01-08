# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    class Haxelib
      include Bibliothecary::Analyser

      def self.file_patterns
        ["haxelib.json"]
      end

      def self.mapping
        {
          match_filename("haxelib.json") => {
            kind: "manifest",
            parser: :parse_manifest,
          },
        }
      end

      def self.parse_manifest(file_contents, options: {})
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
    end
  end
end
