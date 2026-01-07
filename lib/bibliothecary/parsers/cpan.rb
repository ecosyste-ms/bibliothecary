# frozen_string_literal: true

require "yaml"
require "json"

module Bibliothecary
  module Parsers
    class CPAN
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("META.json", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_json_manifest,
          },
          match_filename("META.yml", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_yaml_manifest,
          },
          match_filename("cpanfile", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_cpanfile,
          },
          match_filename("cpanfile.snapshot", case_insensitive: true) => {
            kind: "lockfile",
            parser: :parse_cpanfile_snapshot,
          },
          match_filename("Makefile.PL", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_makefile_pl,
          },
          match_filename("Build.PL", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_build_pl,
          },
        }
      end


      def self.parse_json_manifest(file_contents, options: {})
        manifest = JSON.parse file_contents
        dependencies = manifest["prereqs"].map do |_group, deps|
          map_dependencies(deps, "requires", "runtime", options.fetch(:filename, nil))
        end.flatten
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_yaml_manifest(file_contents, options: {})
        manifest = YAML.load file_contents
        dependencies = map_dependencies(manifest, "requires", "runtime", options.fetch(:filename, nil))
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_cpanfile(file_contents, options: {})
        filename = options.fetch(:filename, nil)
        dependencies = []
        current_phase = "runtime"
        current_feature = nil

        file_contents.each_line do |line|
          line = line.strip

          # Track phase changes: on 'test' => sub {
          if line =~ /\bon\s+['"](\w+)['"]\s*=>/
            current_phase = $1
            next
          end

          # Track feature blocks: feature 'name', 'desc' => sub {
          if line =~ /\bfeature\s+['"]([\w-]+)['"]/
            current_feature = $1
            next
          end

          # End of block - reset to defaults
          if line =~ /^\s*\};\s*$/
            current_phase = "runtime"
            current_feature = nil
            next
          end

          # Parse dependency declarations
          # requires 'Module::Name', 'version';
          # requires 'Module::Name';
          # recommends 'Module::Name', 'version';
          if line =~ /\b(requires|recommends|suggests|conflicts)\s+['"]([^'"]+)['"](?:\s*,\s*['"]?([^'";]+)['"]?)?/
            dep_type = $1
            name = $2
            version = $3&.strip || "*"

            # Map cpanfile phases to our types
            type = case current_phase
                   when "test" then "test"
                   when "develop" then "develop"
                   when "build" then "build"
                   when "configure" then "build"
                   else dep_type == "requires" ? "runtime" : dep_type
                   end

            dependencies << Dependency.new(
              name: name,
              requirement: version,
              type: type,
              platform: "cpan",
              source: filename
            )
          end
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_cpanfile_snapshot(file_contents, options: {})
        filename = options.fetch(:filename, nil)
        dependencies = []

        file_contents.each_line do |line|
          # Match distribution header: Module-Name-1.23
          if (match = line.match(/^  (\S+)-v?([\d._]+)$/))
            dist_name = match[1].gsub("-", "::")
            version = match[2]
            dependencies << Dependency.new(
              name: dist_name,
              requirement: version,
              type: "runtime",
              platform: "cpan",
              source: filename
            )
          end
        end

        ParserResult.new(dependencies: dependencies)
      end

      # Parse Makefile.PL (ExtUtils::MakeMaker format)
      # Looks for PREREQ_PM, BUILD_REQUIRES, TEST_REQUIRES, CONFIGURE_REQUIRES
      def self.parse_makefile_pl(file_contents, options: {})
        filename = options.fetch(:filename, nil)
        dependencies = []

        # Map of hash key names to dependency types
        type_mapping = {
          "PREREQ_PM" => "runtime",
          "BUILD_REQUIRES" => "build",
          "TEST_REQUIRES" => "test",
          "CONFIGURE_REQUIRES" => "build",
        }

        type_mapping.each do |key, type|
          deps = extract_perl_hash(file_contents, key)
          deps.each do |name, version|
            dependencies << Dependency.new(
              name: name,
              requirement: version,
              type: type,
              platform: "cpan",
              source: filename
            )
          end
        end

        ParserResult.new(dependencies: dependencies)
      end

      # Parse Build.PL (Module::Build format)
      # Looks for requires, build_requires, test_requires, configure_requires
      def self.parse_build_pl(file_contents, options: {})
        filename = options.fetch(:filename, nil)
        dependencies = []

        # Map of hash key names to dependency types
        type_mapping = {
          "requires" => "runtime",
          "build_requires" => "build",
          "test_requires" => "test",
          "configure_requires" => "build",
          "recommends" => "runtime",
        }

        type_mapping.each do |key, type|
          deps = extract_perl_hash(file_contents, key)
          deps.each do |name, version|
            dependencies << Dependency.new(
              name: name,
              requirement: version,
              type: type,
              platform: "cpan",
              source: filename
            )
          end
        end

        ParserResult.new(dependencies: dependencies)
      end

      # Extract a Perl hash from source code
      # Handles patterns like: KEY => { 'Module' => '1.0', ... }
      def self.extract_perl_hash(content, key)
        deps = {}

        # Match the hash assignment: KEY => { ... }
        # Use word boundary to avoid matching configure_requires when looking for requires
        pattern = /(?:^|[^\w])#{Regexp.escape(key)}\s*=>\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}/m

        if (match = content.match(pattern))
          hash_content = match[1]

          # Extract 'Module::Name' => 'version' or 'Module::Name' => version patterns
          hash_content.scan(/['"]([^'"]+)['"]\s*=>\s*['"]?([^'",}\s]+)['"]?/) do |name, version|
            # Skip perl version requirements and non-module entries
            next if name == "perl"

            # Normalize version: 0 means any version
            version = "*" if version == "0"
            deps[name] = version
          end
        end

        deps
      end
    end
  end
end
