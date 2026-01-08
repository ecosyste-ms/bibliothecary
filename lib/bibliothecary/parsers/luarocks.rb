# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class LuaRocks
      include Bibliothecary::Analyser

      def self.file_patterns
        ["*.rockspec"]
      end

      def self.mapping
        {
          match_extension(".rockspec") => {
            kind: "manifest",
            parser: :parse_rockspec,
          },
        }
      end

      def self.parse_rockspec(file_contents, options: {})
        source = options.fetch(:filename, nil)
        deps = []

        # Find dependencies table in Lua format
        # dependencies = { "lua >= 5.1", "package ~> 1.0" }
        if file_contents =~ /dependencies\s*=\s*\{([^}]*)\}/m
          deps_block = Regexp.last_match(1)

          # Extract quoted strings from the dependencies table
          deps_block.scan(/"([^"]+)"/).flatten.each do |spec|
            spec = spec.strip
            next if spec.empty?

            # Parse "packagename" or "packagename >= version" or "packagename ~> version"
            # Format: name [operator version]
            if spec =~ /^([a-zA-Z0-9_-]+)\s*(.*)$/
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
