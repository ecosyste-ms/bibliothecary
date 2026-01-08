# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    class CRAN
      include Bibliothecary::Analyser

      REQUIRE_REGEXP = /([a-zA-Z0-9\-_.]+)\s?\(?([><=\s\d.,]+)?\)?/

      def self.file_patterns
        ["DESCRIPTION", "renv.lock"]
      end

      def self.mapping
        {
          match_filename("DESCRIPTION", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_description,
          },
          match_filename("renv.lock") => {
            kind: "lockfile",
            parser: :parse_renv_lock,
          },
        }
      end


      def self.parse_description(file_contents, options: {})
        source = options.fetch(:filename, nil)
        fields = parse_rfc822(file_contents)

        dependencies = parse_deps(fields["Depends"], "depends", source) +
                       parse_deps(fields["Imports"], "imports", source) +
                       parse_deps(fields["Suggests"], "suggests", source) +
                       parse_deps(fields["Enhances"], "enhances", source)

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_rfc822(contents)
        fields = {}
        current_field = nil

        contents.each_line do |line|
          if line =~ /^([A-Za-z][A-Za-z0-9-]*):\s*(.*)/
            current_field = $1
            fields[current_field] = $2.strip
          elsif line =~ /^\s+(.*)/ && current_field
            # Continuation line
            fields[current_field] += " " + $1.strip
          end
        end

        fields
      end

      def self.parse_deps(value, type, source)
        return [] unless value

        value.split(",").map(&:strip).map do |dep_str|
          next if dep_str.empty?

          match = dep_str.match(REQUIRE_REGEXP)
          next unless match

          # Normalize whitespace: collapse multiple spaces, but preserve single space after operator
          requirement = match[2]&.gsub(/\s+/, " ")&.strip || "*"

          Dependency.new(
            name: match[1],
            requirement: requirement,
            type: type,
            source: source,
            platform: platform_name
          )
        end.compact
      end

      def self.parse_renv_lock(file_contents, options: {})
        source = options.fetch(:filename, nil)
        manifest = JSON.parse(file_contents)
        packages = manifest.fetch("Packages", {})

        dependencies = packages.map do |_key, pkg|
          # Only include packages from CRAN repository
          # Skip local packages and packages from other sources like Bioconductor
          repository = pkg["Repository"]
          next unless repository == "CRAN"

          Dependency.new(
            name: pkg["Package"],
            requirement: pkg["Version"],
            type: "runtime",
            source: source,
            platform: platform_name
          )
        end.compact

        ParserResult.new(dependencies: dependencies)
      end
    end
  end
end
