# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class Julia
      include Bibliothecary::Analyser

      def self.file_patterns
        ["REQUIRE", "Project.toml", "Manifest.toml"]
      end

      def self.mapping
        {
          match_filename("REQUIRE", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_require,
          },
          match_filename("Project.toml") => {
            kind: "manifest",
            parser: :parse_project_toml,
          },
          match_filename("Manifest.toml") => {
            kind: "lockfile",
            parser: :parse_manifest_toml,
          },
        }
      end


      def self.parse_require(file_contents, options: {})
        deps = []
        file_contents.split("\n").each do |line|
          next if line.match(/^#/) || line.empty?

          split = line.split(/\s/)
          if line.match(/^@/)
            name = split[1]
            reqs = split[2, split.length].join(" ")
          else
            name = split[0]
            reqs = split[1, split.length].join(" ")
          end
          reqs = "*" if reqs.empty?
          next if name.empty?

          deps << Dependency.new(
            name: name,
            requirement: reqs,
            type: "runtime",
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end
        ParserResult.new(dependencies: deps)
      end

      def self.parse_project_toml(file_contents, options: {})
        source = options.fetch(:filename, "Project.toml")
        manifest = Tomlrb.parse(file_contents)
        deps = []

        manifest.fetch("deps", {}).each do |name, _uuid|
          deps << Dependency.new(
            name: name,
            requirement: "*",
            type: "runtime",
            source: source,
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: deps)
      end

      def self.parse_manifest_toml(file_contents, options: {})
        source = options.fetch(:filename, "Manifest.toml")
        manifest = Tomlrb.parse(file_contents)
        deps = []

        manifest.fetch("deps", {}).each do |name, entries|
          # entries is an array of package entries (usually just one)
          entry = entries.is_a?(Array) ? entries.first : entries
          next unless entry.is_a?(Hash)

          version = entry["version"]
          next unless version

          deps << Dependency.new(
            name: name,
            requirement: version,
            type: "runtime",
            source: source,
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: deps)
      end
    end
  end
end
