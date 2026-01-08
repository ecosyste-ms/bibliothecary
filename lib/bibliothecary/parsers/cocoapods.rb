# frozen_string_literal: true

require "yaml"

module Bibliothecary
  module Parsers
    class CocoaPods
      include Bibliothecary::Analyser

      NAME_VERSION = '(?! )(.*?)(?: \(([^-]*)(?:-(.*))?\))?'
      NAME_VERSION_4 = /^ {4}#{NAME_VERSION}$/

      # Podfile pattern: pod "Name", "version" or pod "Name"
      # Matches: pod 'name' or pod "name" with optional version
      POD_REGEXP = /^\s*pod\s+['"]([^'"]+)['"]\s*(?:,\s*['"]([^'"]+)['"])?/

      # Podspec pattern: .dependency "Name", "version"
      PODSPEC_DEPENDENCY = /\.dependency\s+['"]([^'"]+)['"]\s*(?:,\s*['"]([^'"]+)['"])?/

      def self.file_patterns
        ["Podfile", "*.podspec", "Podfile.lock", "*.podspec.json"]
      end

      def self.mapping
        {
          match_filename("Podfile") => {
            kind: "manifest",
            parser: :parse_podfile,
          },
          match_extension(".podspec") => {
            kind: "manifest",
            parser: :parse_podspec,
            can_have_lockfile: false,
          },
          match_filename("Podfile.lock") => {
            kind: "lockfile",
            parser: :parse_podfile_lock,
          },
          match_extension(".podspec.json") => {
            kind: "manifest",
            parser: :parse_json_manifest,
            can_have_lockfile: false,
          },
        }
      end


      def self.parse_podfile_lock(file_contents, options: {})
        source = options.fetch(:filename, nil)
        dependencies = []

        # Match pod entries: "  - Name (version)" or "  - Name/Subspec (version)"
        # Only process lines in PODS section (before DEPENDENCIES section)
        pods_section = file_contents.split(/^DEPENDENCIES:/)[0]
        pods_section.scan(/^  - ([^\s(]+(?:\/[^\s(]+)?)\s+\(([^)]+)\)/) do |name, version|
          # Take only the base package name (before any /)
          base_name = name.split("/").first
          dependencies << Dependency.new(
            platform: platform_name,
            name: base_name,
            requirement: version,
            type: "runtime",
            source: source
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_podspec(file_contents, options: {})
        source = options.fetch(:filename, nil)
        deps = []
        seen_names = Set.new

        file_contents.each_line do |line|
          match = line.match(PODSPEC_DEPENDENCY)
          next unless match

          name = match[1]
          # Strip subspec path (e.g., "Foo/Bar" -> "Foo")
          base_name = name.split("/").first

          # Deduplicate by base name
          next if seen_names.include?(base_name)
          seen_names.add(base_name)

          deps << Dependency.new(
            platform: platform_name,
            name: base_name,
            requirement: ">= 0",
            type: "runtime",
            source: source
          )
        end

        ParserResult.new(dependencies: deps)
      end

      def self.parse_podfile(file_contents, options: {})
        source = options.fetch(:filename, nil)
        deps = []
        in_conditional = false
        conditional_depth = 0

        file_contents.each_line do |line|
          # Track if/else/elsif blocks to skip pods inside them
          if line =~ /^\s*if\s+/
            in_conditional = true
            conditional_depth += 1
            next
          end
          if line =~ /^\s*(elsif|else)\s*/
            next
          end
          if line =~ /^\s*end\s*$/ && in_conditional
            conditional_depth -= 1
            in_conditional = false if conditional_depth == 0
            next
          end

          # Skip pods inside conditionals
          next if in_conditional

          match = line.match(POD_REGEXP)
          next unless match

          name = match[1]
          version = match[2]

          # Skip pods with special characters like + or subspecs with /
          next if name.include?("+") || name.include?("/")

          requirement = version ? normalize_version(version) : ">= 0"

          deps << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: requirement,
            type: "runtime",
            source: source
          )
        end

        ParserResult.new(dependencies: deps)
      end

      def self.normalize_version(version)
        # If version already has an operator, use as-is
        return version if version =~ /^[~>=<]/
        # Otherwise treat as exact version
        "= #{version}"
      end

      def self.parse_json_manifest(file_contents, options: {})
        manifest = JSON.parse(file_contents)
        dependencies = manifest["dependencies"].inject([]) do |deps, dep|
          deps.push(Dependency.new(
                      platform: platform_name,
                      name: dep[0],
                      requirement: dep[1],
                      type: "runtime",
                      source: options.fetch(:filename, nil)
                    ))
        end.uniq
        ParserResult.new(dependencies: dependencies)
      end
    end
  end
end
