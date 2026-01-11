# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class Alpm
      include Bibliothecary::Analyser

      def self.file_patterns
        ["PKGBUILD"]
      end

      def self.mapping
        {
          match_filename("PKGBUILD") => {
            kind: "manifest",
            parser: :parse_pkgbuild,
            can_have_lockfile: false,
          },
        }
      end

      def self.parse_pkgbuild(file_contents, options: {})
        source = options.fetch(:filename, "PKGBUILD")
        dependencies = []

        # Parse depends (runtime)
        extract_variable(file_contents, "depends").each do |dep|
          name, requirement = parse_dependency(dep)
          dependencies << Dependency.new(
            name: name,
            requirement: requirement || "*",
            type: "runtime",
            source: source,
            platform: platform_name
          )
        end

        # Parse makedepends (build)
        extract_variable(file_contents, "makedepends").each do |dep|
          name, requirement = parse_dependency(dep)
          dependencies << Dependency.new(
            name: name,
            requirement: requirement || "*",
            type: "build",
            source: source,
            platform: platform_name
          )
        end

        # Parse checkdepends (test)
        extract_variable(file_contents, "checkdepends").each do |dep|
          name, requirement = parse_dependency(dep)
          dependencies << Dependency.new(
            name: name,
            requirement: requirement || "*",
            type: "test",
            source: source,
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.extract_variable(contents, var_name)
        # PKGBUILD uses bash array syntax: depends=('pkg1' 'pkg2') or depends=(pkg1 pkg2)
        # Can also span multiple lines
        pattern = /^#{var_name}=\(([^)]*)\)/m
        match = contents.match(pattern)
        return [] unless match

        # Extract items, handling both quoted and unquoted formats
        # 'pkg1' 'pkg2' or "pkg1" "pkg2" or pkg1 pkg2
        items = match[1].scan(/['"]([^'"]+)['"]|(\S+)/).flatten.compact
        items.reject { |d| d.empty? || d.start_with?("$") }
      end

      def self.parse_dependency(dep_string)
        # Parse version constraints like "glibc>=2.17" or "openssl>1.1"
        # Operators: >=, <=, >, <, =
        if dep_string =~ /^(.+?)([><=]+)(.+)$/
          [$1, "#{$2}#{$3}"]
        else
          [dep_string, nil]
        end
      end
    end
  end
end
