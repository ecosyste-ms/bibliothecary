# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    class Dub
      include Bibliothecary::Analyser
      extend Bibliothecary::MultiParsers::JSONRuntime

      # Matches: dependency "name" version="~>1.0"
      SDL_DEPENDENCY_REGEXP = /^dependency\s+"([^"]+)"(?:\s+version="([^"]+)")?/

      def self.mapping
        {
          match_filename("dub.json") => {
            kind: "manifest",
            parser: :parse_json_runtime_manifest,
          },
          match_filename("dub.sdl") => {
            kind: "manifest",
            parser: :parse_sdl_manifest,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

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
