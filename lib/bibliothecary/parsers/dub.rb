# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    class Dub
      include Bibliothecary::Analyser

      SDL_DEPENDENCY_REGEXP = /^dependency\s+"([^"]+)"(?:\s+version="([^"]+)")?/

      def self.file_patterns
        ["dub.json", "dub.sdl"]
      end

      def self.mapping
        {
          match_filename("dub.json") => {
            kind: "manifest",
            parser: :parse_json_manifest,
          },
          match_filename("dub.sdl") => {
            kind: "manifest",
            parser: :parse_sdl_manifest,
          },
        }
      end

      def self.parse_json_manifest(file_contents, options: {})
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

      def self.parse_sdl_manifest(file_contents, options: {})
        source = options.fetch(:filename, nil)
        deps = []

        file_contents.each_line do |line|
          match = line.match(SDL_DEPENDENCY_REGEXP)
          next unless match

          deps << Dependency.new(
            platform: platform_name,
            name: match[1],
            requirement: match[2] || ">= 0",
            type: :runtime,
            source: source
          )
        end

        ParserResult.new(dependencies: deps.uniq)
      end
    end
  end
end
