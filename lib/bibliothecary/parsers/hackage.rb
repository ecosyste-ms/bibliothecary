require "json"

module Bibliothecary
  module Parsers
    class Hackage
      include Bibliothecary::Analyser

      # Matches dependency lines like: aeson == 1.1.* or base >= 4.9 && < 4.11
      # Package names can contain letters, numbers, and hyphens
      DEPENDENCY_REGEXP = /^\s*([a-zA-Z][a-zA-Z0-9-]*)\s*((?:[<>=!]+\s*[\d.*]+(?:\s*&&\s*[<>=!]+\s*[\d.*]+)*)?)/

      # Matches build-tool-depends format: package:tool == version
      BUILD_TOOL_REGEXP = /^\s*([a-zA-Z][a-zA-Z0-9-]*):[a-zA-Z][a-zA-Z0-9-]*\s*((?:[<>=!]+\s*[\d.*]+(?:\s*&&\s*[<>=!]+\s*[\d.*]+)*)?)/

      # Matches stack.yaml.lock hackage entries like: hackage: fuzzyset-0.2.4@sha256:...
      STACK_LOCK_REGEXP = /hackage:\s*([a-zA-Z0-9-]+)-([0-9.]+)@/

      def self.file_patterns
        ["*.cabal", "*cabal.config", "stack.yaml.lock", "cabal.project.freeze"]
      end

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
          match_filename("stack.yaml.lock") => {
            kind: "lockfile",
            parser: :parse_stack_yaml_lock,
          },
          match_filename("cabal.project.freeze") => {
            kind: "lockfile",
            parser: :parse_cabal_project_freeze,
          },
        }
      end


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
        deps = []

        # Parse RFC822-style format: constraints: pkg1 ==1.0, pkg2 ==2.0, ...
        # Values can span multiple lines (continuation lines start with whitespace)
        constraints = nil
        file_contents.each_line do |line|
          if line =~ /^constraints:\s*(.*)/i
            constraints = $1.strip
          elsif line =~ /^\s+(.*)/ && constraints
            constraints += " " + $1.strip
          elsif line =~ /^[a-z]/i && constraints
            break
          end
        end

        return ParserResult.new(dependencies: []) unless constraints

        constraints.split(",").each do |dep_str|
          dep_str = dep_str.strip
          next if dep_str.empty?

          # Format: package ==version or package ==version.*
          dep = dep_str.delete("==").split(/\s+/)
          deps << Dependency.new(
            platform: platform_name,
            name: dep[0],
            requirement: dep[1] || "*",
            type: "runtime",
            source: source
          )
        end

        ParserResult.new(dependencies: deps)
      end

      def self.parse_stack_yaml_lock(file_contents, options: {})
        source = options.fetch(:filename, "stack.yaml.lock")
        deps = []

        file_contents.each_line do |line|
          match = line.match(STACK_LOCK_REGEXP)
          next unless match

          deps << Dependency.new(
            platform: platform_name,
            name: match[1],
            requirement: match[2],
            type: "runtime",
            source: source
          )
        end

        ParserResult.new(dependencies: deps)
      end

      def self.parse_cabal_project_freeze(file_contents, options: {})
        source = options.fetch(:filename, "cabal.project.freeze")
        deps = []

        # Parse constraints field which can span multiple lines
        # Format: constraints: any.pkg ==version, any.pkg2 ==version2, ...
        # Also handles flag constraints like: any.pkg +flag -flag2
        constraints = nil
        file_contents.each_line do |line|
          if line =~ /^constraints:\s*(.*)/i
            constraints = $1.strip
          elsif line =~ /^\s+(.*)/ && constraints
            constraints += " " + $1.strip
          elsif line =~ /^[a-z]/i && constraints
            break
          end
        end

        return ParserResult.new(dependencies: []) unless constraints

        constraints.split(",").each do |dep_str|
          dep_str = dep_str.strip
          next if dep_str.empty?

          # Format: any.package ==version or any.package +flag -flag
          # Skip flag-only entries (no version constraint)
          next unless dep_str.include?("==")

          # Remove "any." prefix and parse
          dep_str = dep_str.sub(/^any\./, "")

          # Extract name and version: "package ==version" or "package ==version +flag"
          match = dep_str.match(/^([a-zA-Z][a-zA-Z0-9-]*)\s*==\s*([\d.]+)/)
          next unless match

          deps << Dependency.new(
            platform: platform_name,
            name: match[1],
            requirement: match[2],
            type: "runtime",
            source: source
          )
        end

        ParserResult.new(dependencies: deps)
      end
    end
  end
end
