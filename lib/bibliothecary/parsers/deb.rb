# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class Deb
      include Bibliothecary::Analyser

      def self.file_patterns
        ["debian/control", "control"]
      end

      def self.mapping
        {
          match_filename("debian/control") => {
            kind: "manifest",
            parser: :parse_control,
            can_have_lockfile: false,
          },
          match_filename("control") => {
            kind: "manifest",
            parser: :parse_control,
            can_have_lockfile: false,
          },
        }
      end

      BUILD_DEP_FIELDS = %w[Build-Depends Build-Depends-Indep Build-Depends-Arch].freeze
      RUNTIME_DEP_FIELDS = %w[Depends Pre-Depends Recommends Suggests].freeze

      def self.parse_control(file_contents, options: {})
        source = options.fetch(:filename, nil)
        dependencies = []

        # Parse the control file - it's in RFC 822 format with continuation lines
        # Fields can span multiple lines if continuation lines start with whitespace
        fields = parse_fields(file_contents)

        # Build dependencies
        BUILD_DEP_FIELDS.each do |field_name|
          next unless fields[field_name.downcase]

          parse_dependency_list(fields[field_name.downcase]).each do |dep|
            dependencies << Dependency.new(
              name: dep[:name],
              requirement: dep[:requirement] || "*",
              type: "build",
              source: source,
              platform: platform_name
            )
          end
        end

        # Runtime dependencies
        RUNTIME_DEP_FIELDS.each do |field_name|
          next unless fields[field_name.downcase]

          parse_dependency_list(fields[field_name.downcase]).each do |dep|
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

      def self.parse_fields(contents)
        fields = {}
        current_field = nil
        current_value = []

        contents.each_line do |line|
          if line =~ /^(\S+):\s*(.*)$/
            # Save previous field
            if current_field
              fields[current_field] = current_value.join(" ").strip
            end
            current_field = $1.downcase
            current_value = [$2]
          elsif line =~ /^\s+(.*)$/ && current_field
            # Continuation line
            current_value << $1
          elsif line.strip.empty?
            # Empty line - save current field and reset
            if current_field
              fields[current_field] = current_value.join(" ").strip
            end
            current_field = nil
            current_value = []
          end
        end

        # Save last field
        if current_field
          fields[current_field] = current_value.join(" ").strip
        end

        fields
      end

      def self.parse_dependency_list(dep_string)
        deps = []

        # Dependencies are comma-separated
        dep_string.split(/,/).each do |dep|
          dep = dep.strip
          next if dep.empty?
          next if dep.start_with?("$") # Skip substitution variables like ${shlibs:Depends}

          # Handle alternatives (pkg1 | pkg2) - just take the first one
          dep = dep.split("|").first.strip

          # Parse package name and optional version constraint
          # Format: package (>= 1.0) or just package
          if dep =~ /^(\S+)\s*\(([^)]+)\)$/
            name = $1
            constraint = $2.strip
            deps << { name: name, requirement: constraint }
          elsif dep =~ /^(\S+)$/
            deps << { name: $1, requirement: nil }
          end
        end

        deps
      end
    end
  end
end
