# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class Apk
      include Bibliothecary::Analyser

      def self.file_patterns
        ["APKBUILD"]
      end

      def self.mapping
        {
          match_filename("APKBUILD") => {
            kind: "manifest",
            parser: :parse_apkbuild,
            can_have_lockfile: false,
          },
        }
      end

      def self.parse_apkbuild(file_contents, options: {})
        source = options.fetch(:filename, "APKBUILD")
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
        # Match variable assignment with double or single quotes, handling multi-line with backslash
        # Examples:
        #   depends="foo bar"
        #   makedepends="foo
        #   bar"
        #   checkdepends='foo bar'
        pattern = /^#{var_name}=["']([^"']*?)["']/m
        match = contents.match(pattern)
        return [] unless match

        # Split on whitespace and filter out empty strings, negated packages (!), and variable references ($)
        match[1].split(/\s+/).reject { |d| d.empty? || d.start_with?("!") || d.start_with?("$") }
      end

      def self.parse_dependency(dep_string)
        # Parse version constraints like "openssl-dev>3" or "zlib-dev>=1.2.3"
        # Operators: >=, <=, >, <, =, ~
        if dep_string =~ /^(.+?)([><=~]+)(.+)$/
          [$1, "#{$2}#{$3}"]
        else
          [dep_string, nil]
        end
      end
    end
  end
end
