require "json"

module Bibliothecary
  module Parsers
    class Hex
      include Bibliothecary::Analyser

      # Matches mix.lock entries: "name": {:hex, :name, "version", ...
      # or "name": {:git, "url", "ref", ...
      HEX_LOCK_REGEXP = /"([^"]+)":\s*\{:hex,\s*:[^,]+,\s*"([^"]+)"/
      GIT_LOCK_REGEXP = /"([^"]+)":\s*\{:git,\s*"([^"]+)",\s*"([^"]+)"/

      def self.mapping
        {
          match_filename("mix.exs") => {
            kind: "manifest",
            parser: :parse_mix,
          },
          match_filename("mix.lock") => {
            kind: "lockfile",
            parser: :parse_mix_lock,
          },
        }
      end


      def self.parse_mix(file_contents, options: {})
        source = options.fetch(:filename, "mix.exs")
        deps = []

        # Remove comments before parsing
        content = file_contents.gsub(/#.*$/, "")

        # Match deps in the dependencies list: {:name, "~> version"} or {:name, ">= version"}
        # Format: {:dep_name, "requirement"} or {:dep_name, "requirement", opts}
        content.scan(/\{:(\w+),\s*"([^"]+)"/) do |name, requirement|
          deps << Dependency.new(
            platform: platform_name,
            name: name.to_s,
            requirement: requirement,
            type: "runtime",
            source: source
          )
        end

        ParserResult.new(dependencies: deps)
      end

      def self.parse_mix_lock(file_contents, options: {})
        source = options.fetch(:filename, "mix.lock")
        deps = []

        # Match hex packages: "name": {:hex, :name, "version", ...
        file_contents.scan(HEX_LOCK_REGEXP) do |name, version|
          deps << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: version,
            type: "runtime",
            source: source
          )
        end

        # Match git packages: "name": {:git, "url", "ref", ...
        file_contents.scan(GIT_LOCK_REGEXP) do |name, _url, ref|
          deps << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: ref,
            type: "runtime",
            source: source
          )
        end

        ParserResult.new(dependencies: deps)
      end
    end
  end
end
