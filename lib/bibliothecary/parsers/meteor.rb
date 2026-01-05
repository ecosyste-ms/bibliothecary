# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    class Meteor
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("versions.json") => {
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
