# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class Nimble
      include Bibliothecary::Analyser

      # Matches requires statements like: requires "nim >= 1.0.0", "chronos >= 3.0.0"
      # or: requires "packagename"
      REQUIRES_REGEXP = /^\s*requires\s+"([^"]+)"/

      def self.file_patterns
        ["*.nimble"]
      end

      def self.mapping
        {
          match_extension(".nimble") => {
            kind: "manifest",
            parser: :parse_nimble,
          },
        }
      end

      def self.parse_nimble(file_contents, options: {})
        source = options.fetch(:filename, nil)
        deps = []

        file_contents.each_line do |line|
          next unless line.strip.start_with?("requires")

          # Extract all quoted strings from requires lines
          # handles: requires "pkg1", "pkg2 >= 1.0"
          line.scan(/"([^"]+)"/).flatten.each do |spec|
            spec = spec.strip
            next if spec.empty?

            # Parse "packagename" or "packagename >= version" or "packagename == version"
            if spec =~ /^([a-zA-Z0-9_]+)\s*(.*)$/
              name = Regexp.last_match(1)
              requirement = Regexp.last_match(2).strip
              requirement = "*" if requirement.empty?

              deps << Dependency.new(
                name: name,
                requirement: requirement,
                type: "runtime",
                source: source,
                platform: platform_name
              )
            end
          end
        end

        ParserResult.new(dependencies: deps)
      end
    end
  end
end
