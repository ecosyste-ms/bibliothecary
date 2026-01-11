# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class Rpm
      include Bibliothecary::Analyser

      def self.file_patterns
        ["*.spec"]
      end

      def self.mapping
        {
          match_extension(".spec") => {
            kind: "manifest",
            parser: :parse_spec,
            can_have_lockfile: false,
          },
        }
      end

      def self.parse_spec(file_contents, options: {})
        source = options.fetch(:filename, nil)
        dependencies = []

        # Parse BuildRequires (build dependencies)
        file_contents.scan(/^BuildRequires:\s*(.+)$/i) do |match|
          parse_dependency_line(match[0]).each do |dep|
            dependencies << Dependency.new(
              name: dep[:name],
              requirement: dep[:requirement] || "*",
              type: "build",
              source: source,
              platform: platform_name
            )
          end
        end

        # Parse Requires (runtime dependencies), including Requires(pre), Requires(post), etc.
        file_contents.scan(/^Requires(?:\([^)]+\))?:\s*(.+)$/i) do |match|
          parse_dependency_line(match[0]).each do |dep|
            dependencies << Dependency.new(
              name: dep[:name],
              requirement: dep[:requirement] || "*",
              type: "runtime",
              source: source,
              platform: platform_name
            )
          end
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_dependency_line(line)
        # Dependencies can be comma or whitespace separated
        # Each dependency can have version constraints like: pkg >= 1.0
        # Also filter out RPM macros like %{name}
        deps = []

        # Split on commas first, then handle each part
        line.split(/,/).each do |part|
          part = part.strip
          next if part.empty?
          next if part.start_with?("%") # Skip RPM macros
          next if part.start_with?("/") # Skip file paths like /bin/sh

          # Check for version constraint (pkg >= 1.0, pkg < 2.0, etc.)
          if part =~ /^(\S+)\s+([<>=]+)\s*(\S+)$/
            deps << { name: $1, requirement: "#{$2} #{$3}" }
          elsif part =~ /^(\S+)$/
            deps << { name: $1, requirement: nil }
          end
        end

        deps
      end
    end
  end
end
