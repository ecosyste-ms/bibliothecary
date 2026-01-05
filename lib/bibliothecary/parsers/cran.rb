# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class CRAN
      include Bibliothecary::Analyser

      REQUIRE_REGEXP = /([a-zA-Z0-9\-_.]+)\s?\(?([><=\s\d.,]+)?\)?/

      def self.mapping
        {
          match_filename("DESCRIPTION", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_description,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

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
    end
  end
end
