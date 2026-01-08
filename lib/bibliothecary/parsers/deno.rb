# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    class Deno
      include Bibliothecary::Analyser

      def self.file_patterns
        ["deno.json", "deno.jsonc", "deno.lock"]
      end

      def self.mapping
        {
          match_filename("deno.json") => {
            kind: "manifest",
            parser: :parse_manifest,
          },
          match_filename("deno.jsonc") => {
            kind: "manifest",
            parser: :parse_manifest,
          },
          match_filename("deno.lock") => {
            kind: "lockfile",
            parser: :parse_lockfile,
          },
        }
      end

      def self.parse_manifest(file_contents, options: {})
        manifest = JSON.parse(file_contents)
        source = options.fetch(:filename, nil)

        dependencies = manifest.fetch("imports", {}).map do |alias_name, specifier|
          name, requirement = parse_specifier(specifier)
          next unless name

          Dependency.new(
            name: name,
            requirement: requirement,
            type: "runtime",
            source: source,
            platform: platform_name
          )
        end.compact

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_lockfile(file_contents, options: {})
        manifest = JSON.parse(file_contents)
        source = options.fetch(:filename, nil)

        dependencies = manifest.fetch("specifiers", {}).map do |specifier, resolved_version|
          name, _requirement = parse_specifier(specifier)
          next unless name

          Dependency.new(
            name: name,
            requirement: resolved_version,
            type: "runtime",
            source: source,
            platform: platform_name
          )
        end.compact

        ParserResult.new(dependencies: dependencies)
      end

      # Parses specifiers like:
      #   "npm:chalk@1" => ["chalk", "1"]
      #   "npm:chalk" => ["chalk", "*"]
      #   "jsr:@std/path@^1" => ["@std/path", "^1"]
      #   "jsr:@std/path" => ["@std/path", "*"]
      def self.parse_specifier(specifier)
        return nil unless specifier.start_with?("npm:", "jsr:")

        # Remove the protocol prefix
        without_protocol = specifier.sub(/^(npm|jsr):/, "")

        # Handle scoped packages (@scope/name@version)
        if without_protocol.start_with?("@")
          # Split on @ but keep the first @ for the scope
          parts = without_protocol[1..].split("@", 2)
          name = "@#{parts[0]}"
          requirement = parts[1] || "*"
        else
          # Regular package (name@version)
          name, requirement = without_protocol.split("@", 2)
          requirement ||= "*"
        end

        [name, requirement]
      end
    end
  end
end
