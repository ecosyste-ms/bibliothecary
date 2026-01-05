# frozen_string_literal: true

require "bundler"

module Bibliothecary
  module Parsers
    class Rubygems
      include Bibliothecary::Analyser
      extend Bibliothecary::MultiParsers::BundlerLikeManifest

      NAME_VERSION = '(?! )(.*?)(?: \(([^-]*)(?:-(.*))?\))?'
      NAME_VERSION_4 = /^ {4}#{NAME_VERSION}$/
      BUNDLED_WITH = /BUNDLED WITH/

      # Gemfile patterns
      GEM_REGEXP = /^\s*gem\s+['"]([^'"]+)['"]\s*(?:,\s*['"]([^'"]+)['"])?/
      GROUP_START = /^\s*group\s+(.+?)\s+do/
      BLOCK_END = /^\s*end\s*$/

      # Gemspec pattern - captures type in first group
      GEMSPEC_DEPENDENCY = /\.add_(development_|runtime_)?dependency\s*\(?\s*['"]([^'"]+)['"]\s*(?:,\s*['"]([^'"]+)['"])?(?:\s*,\s*['"]([^'"]+)['"])?\s*\)?/

      def self.mapping
        {
          match_filenames("Gemfile", "gems.rb") => {
            kind: "manifest",
            parser: :parse_gemfile,
            related_to: %w[manifest lockfile],
          },
          match_extension(".gemspec") => {
            kind: "manifest",
            parser: :parse_gemspec,
            related_to: %w[manifest lockfile],
          },
          match_filenames("Gemfile.lock", "gems.locked") => {
            kind: "lockfile",
            parser: :parse_gemfile_lock,
            related_to: %w[manifest lockfile],
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_gemfile_lock(file_contents, options: {})
        source = options.fetch(:filename, nil)
        dependencies = []

        file_contents.each_line do |line|
          line = line.chomp.gsub(/\r$/, "")
          next unless (match = line.match(NAME_VERSION_4))

          name, version, _platform = match.captures
          next if name.nil? || name.empty?

          dependencies << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: version,
            type: "runtime",
            source: source
          )
        end

        if (bundler_dep = parse_bundler(file_contents, source))
          dependencies << bundler_dep
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_gemfile(file_contents, options: {})
        source = options.fetch(:filename, nil)
        deps = []
        current_type = "runtime"
        block_depth = 0

        file_contents.each_line do |line|
          # Track group blocks
          if (group_match = line.match(GROUP_START))
            block_depth += 1
            groups = group_match[1]
            current_type = groups.include?(":development") ? "development" : "runtime"
            next
          end

          if line.match?(BLOCK_END) && block_depth > 0
            block_depth -= 1
            current_type = "runtime" if block_depth == 0
            next
          end

          # Match gem declarations
          if (match = line.match(GEM_REGEXP))
            name = match[1]
            version = match[2]
            requirement = version ? "= #{version}" : ">= 0"

            deps << Dependency.new(
              platform: platform_name,
              name: name,
              requirement: requirement,
              type: current_type,
              source: source
            )
          end
        end

        ParserResult.new(dependencies: deps)
      end

      def self.parse_gemspec(file_contents, options: {})
        source = options.fetch(:filename, nil)
        deps = []

        file_contents.each_line do |line|
          match = line.match(GEMSPEC_DEPENDENCY)
          next unless match

          type_prefix, name, ver1, ver2 = match.captures
          type = type_prefix == "development_" ? "development" : "runtime"
          requirement = build_requirement(ver1, ver2)

          deps << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: requirement,
            type: type,
            source: source
          )
        end

        ParserResult.new(dependencies: deps)
      end

      def self.build_requirement(ver1, ver2)
        if ver1 && ver2
          "#{ver1}, #{ver2}"
        elsif ver1
          ver1
        else
          ">= 0"
        end
      end

      def self.parse_bundler(file_contents, source = nil)
        bundled_with_index = file_contents.lines(chomp: true).find_index { |line| line.match(BUNDLED_WITH) }
        return nil unless bundled_with_index

        version = file_contents.lines(chomp: true).fetch(bundled_with_index + 1, nil)&.strip
        return nil unless version && !version.empty?

        Dependency.new(
          name: "bundler",
          requirement: version,
          type: "runtime",
          source: source,
          platform: platform_name
        )
      end
    end
  end
end
