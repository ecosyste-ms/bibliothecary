require "json"
require "deb_control"

module Bibliothecary
  module Parsers
    class Hackage
      include Bibliothecary::Analyser

      # Matches dependency lines like: aeson == 1.1.* or base >= 4.9 && < 4.11
      # Package names can contain letters, numbers, and hyphens
      DEPENDENCY_REGEXP = /^\s*([a-zA-Z][a-zA-Z0-9-]*)\s*((?:[<>=!]+\s*[\d.*]+(?:\s*&&\s*[<>=!]+\s*[\d.*]+)*)?)/

      # Matches build-tool-depends format: package:tool == version
      BUILD_TOOL_REGEXP = /^\s*([a-zA-Z][a-zA-Z0-9-]*):[a-zA-Z][a-zA-Z0-9-]*\s*((?:[<>=!]+\s*[\d.*]+(?:\s*&&\s*[<>=!]+\s*[\d.*]+)*)?)/

      def self.mapping
        {
          match_extension(".cabal") => {
            kind: "manifest",
            parser: :parse_cabal,
          },
          match_extension("cabal.config") => {
            kind: "lockfile",
            parser: :parse_cabal_config,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)
      add_multi_parser(Bibliothecary::MultiParsers::Spdx)

      def self.parse_cabal(file_contents, options: {})
        source = options.fetch(:filename, "package.cabal")
        deps = []

        # Track current section type
        current_section = nil
        in_build_depends = false
        in_build_tool_depends = false
        current_deps_buffer = []

        file_contents.each_line do |line|
          # Check for section headers (library, executable, test-suite, benchmark)
          if line =~ /^(library|executable|test-suite|benchmark)\b/i
            current_section = $1.downcase
            in_build_depends = false
            in_build_tool_depends = false
            next
          end

          # Check for build-depends: or build-tool-depends: (can be at any indentation level)
          if line =~ /^\s*build-depends\s*:/i
            in_build_depends = true
            in_build_tool_depends = false
            # Extract deps from same line after colon
            deps_part = line.sub(/^\s*build-depends\s*:/i, "")
            parse_deps_line(deps_part, deps, current_section, "build-depends", source)
            next
          end

          if line =~ /^\s*build-tool-depends\s*:/i
            in_build_tool_depends = true
            in_build_depends = false
            # Extract deps from same line after colon
            deps_part = line.sub(/^\s*build-tool-depends\s*:/i, "")
            parse_deps_line(deps_part, deps, current_section, "build-tool-depends", source)
            next
          end

          # Check for other field headers that end depends section
          # Field headers are like "field-name:" but NOT "package:tool" (build-tool-depends format)
          # Build-tool-depends entries have format: package:tool version-constraint
          if line =~ /^\s*([a-z][a-z0-9-]*)\s*:/i
            field_name = $1
            # If this looks like a field header (not package:tool), end the depends section
            unless line =~ /^\s*[a-z][a-z0-9-]*:[a-z][a-z0-9-]*\s+/i
              in_build_depends = false
              in_build_tool_depends = false
              next
            end
          end

          # Continue parsing dependencies if in a depends section and line is indented
          if (in_build_depends || in_build_tool_depends) && line =~ /^\s+/
            dep_type = in_build_tool_depends ? "build-tool-depends" : "build-depends"
            parse_deps_line(line, deps, current_section, dep_type, source)
          elsif line !~ /^\s/
            # Non-indented line that's not a section header ends depends
            in_build_depends = false
            in_build_tool_depends = false
          end
        end

        ParserResult.new(dependencies: deps)
      end

      def self.parse_deps_line(line, deps, section, dep_type, source)
        # Split by comma and parse each dep
        line.split(",").each do |dep_str|
          dep_str = dep_str.strip
          next if dep_str.empty?

          # Use different regex for build-tool-depends (package:tool format)
          regex = dep_type == "build-tool-depends" ? BUILD_TOOL_REGEXP : DEPENDENCY_REGEXP
          match = dep_str.match(regex)
          next unless match

          name = match[1]
          requirement = match[2]&.strip
          requirement = "*" if requirement.nil? || requirement.empty?
          # Normalize spacing: "== 1.1.*" -> "==1.1.*", ">= 4.9 && < 4.11" -> ">=4.9 && <4.11"
          requirement = requirement.gsub(/([<>=!]+)\s+/, '\1').gsub(/\s+(&&)\s+/, ' \1 ')

          # Determine type based on section and dep_type
          type = determine_dep_type(section, dep_type)

          deps << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: requirement,
            type: type,
            source: source
          )
        end
      end

      def self.determine_dep_type(section, dep_type)
        if dep_type == "build-tool-depends"
          "build"
        elsif section == "test-suite"
          "test"
        elsif section == "benchmark"
          "benchmark"
        else
          "runtime"
        end
      end

      def self.parse_cabal_config(file_contents, options: {})
        source = options.fetch(:filename, "cabal.config")
        manifest = DebControl::ControlFileBase.parse(file_contents)
        deps_raw = manifest.first["constraints"].delete("\n").split(",").map(&:strip)
        deps = deps_raw.map do |dependency|
          dep = dependency.delete("==").split(" ")
          Dependency.new(
            platform: platform_name,
            name: dep[0],
            requirement: dep[1] || "*",
            type: "runtime",
            source: source
          )
        end
        ParserResult.new(dependencies: deps)
      end
    end
  end
end
