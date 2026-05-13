# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    class Lean
      include Bibliothecary::Analyser

      REQUIRE_REGEXP = /
        require\s+
        (?:"(?<scope>[^"]+)"\s*\/\s*)?
        (?:"(?<name_str>[^"]+)"|«(?<name_g>[^»]+)»|(?<name_id>[A-Za-z_][A-Za-z0-9_]*))
        (?:\s*@\s*(?:git\s+)?"(?<version>[^"]+)")?
        (?:\s*from\s+(?:git\s+"(?<git>[^"]+)"(?:\s*@\s*"(?<rev>[^"]+)")?|"(?<path>[^"]+)"))?
      /x

      def self.file_patterns
        ["lakefile.toml", "lakefile.lean", "lake-manifest.json"]
      end

      def self.mapping
        {
          match_filename("lakefile.toml") => {
            kind: "manifest",
            parser: :parse_lakefile_toml,
            related_to: ["lockfile"],
          },
          match_filename("lakefile.lean") => {
            kind: "manifest",
            parser: :parse_lakefile_lean,
            related_to: ["lockfile"],
          },
          match_filename("lake-manifest.json") => {
            kind: "lockfile",
            parser: :parse_lake_manifest,
            related_to: ["manifest"],
          },
        }
      end

      def self.scoped_name(scope, name)
        scope.to_s.empty? ? name : "#{scope}/#{name}"
      end

      def self.parse_lakefile_toml(file_contents, options: {})
        source = options.fetch(:filename, "lakefile.toml")
        manifest = Tomlrb.parse(file_contents)
        deps = []

        manifest.fetch("require", []).each do |req|
          src = req["source"] || {}
          git = req["git"] || src["git"] || src["url"]
          rev = req["rev"] || src["rev"]
          path = req["path"] || src["path"]

          next if path && !git

          deps << Dependency.new(
            name: scoped_name(req["scope"], req["name"]),
            requirement: req["version"] || rev,
            type: "runtime",
            direct: true,
            source: source,
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: deps, project_name: manifest["name"])
      end

      def self.parse_lakefile_lean(file_contents, options: {})
        source = options.fetch(:filename, "lakefile.lean")
        deps = []

        content = file_contents.lines.map do |line|
          if (i = line.index("--")) && !line[0, i].include?('"')
            line[0, i]
          else
            line
          end
        end.join

        content.scan(REQUIRE_REGEXP) do
          m = Regexp.last_match
          name = m[:name_str] || m[:name_g] || m[:name_id]
          next if name.nil?
          next if m[:path] && !m[:git]

          deps << Dependency.new(
            name: scoped_name(m[:scope], name),
            requirement: m[:version] || m[:rev],
            type: "runtime",
            direct: true,
            source: source,
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: deps)
      end

      def self.parse_lake_manifest(file_contents, options: {})
        source = options.fetch(:filename, "lake-manifest.json")
        manifest = JSON.parse(file_contents)
        deps = []

        manifest.fetch("packages", []).each do |pkg|
          next if pkg["type"] == "path"

          name = pkg["name"].to_s.delete("«»")
          deps << Dependency.new(
            name: scoped_name(pkg["scope"], name),
            requirement: pkg["rev"] || pkg["inputRev"],
            type: "runtime",
            direct: !pkg["inherited"],
            source: source,
            platform: platform_name
          )
        end

        project_name = manifest["name"].to_s.delete("«»")
        project_name = nil if project_name.empty?
        ParserResult.new(dependencies: deps, project_name: project_name)
      end
    end
  end
end
