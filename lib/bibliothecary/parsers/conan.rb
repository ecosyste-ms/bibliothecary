# frozen_string_literal: true

module Bibliothecary
  module Parsers
    class Conan
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("conanfile.py") => {
            kind: "manifest",
            parser: :parse_conanfile_py,
          },
          match_filename("conanfile.txt") => {
            kind: "manifest",
            parser: :parse_conanfile_txt,
          },
          match_filename("conan.lock") => {
            kind: "lockfile",
            parser: :parse_lockfile,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      REQUIRES_PATTERN = /self\.requires\(\s*["']([^"']+)["']/

      def self.parse_conanfile_py(file_contents, options: {})
        dependencies = []

        file_contents.scan(REQUIRES_PATTERN).each do |match|
          name, version = parse_conan_reference(match[0])
          next if name.nil? || name.empty?

          dependencies << Dependency.new(
            name: name,
            requirement: version || "*",
            type: "runtime",
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_conanfile_txt(file_contents, options: {})
        dependencies = []
        current_section = nil

        file_contents.each_line do |line|
          line = line.strip
          next if line.empty? || line.start_with?("#")

          if line.match?(/^\[([^\]]+)\]$/)
            current_section = line[1..-2]
            next
          end

          next unless %w[requires build_requires].include?(current_section)

          name, version = parse_conan_reference(line)
          next if name.nil? || name.empty?

          dependencies << Dependency.new(
            name: name,
            requirement: version || "*",
            type: current_section == "requires" ? "runtime" : "development",
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_lockfile(file_contents, options: {})
        manifest = JSON.parse(file_contents)

        if manifest.dig("graph_lock", "nodes")
          parse_v1_lockfile(manifest, options: options)
        else
          parse_v2_lockfile(manifest, options: options)
        end
      end

      def self.parse_v1_lockfile(lockfile, options: {})
        dependencies = []

        lockfile["graph_lock"]["nodes"].each_value do |node|
          next if node["path"] && !node["path"].empty?

          ref = node["pref"] || node["ref"]
          next unless ref

          name, version = parse_conan_reference(ref)
          next if name.nil? || name.empty?

          type = node["context"] == "build" ? "development" : "runtime"

          dependencies << Dependency.new(
            name: name,
            requirement: version || "*",
            type: type,
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_v2_lockfile(lockfile, options: {})
        dependencies = []

        parse_requires(dependencies, lockfile["requires"], "runtime", options)
        parse_requires(dependencies, lockfile["build_requires"], "development", options)
        parse_requires(dependencies, lockfile["python_requires"], "development", options)

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_requires(dependencies, requires, type, options)
        return unless requires&.any?

        requires.each do |ref|
          name, version = parse_conan_reference(ref)
          next if name.nil? || name.empty?

          dependencies << Dependency.new(
            name: name,
            requirement: version || "*",
            type: type,
            source: options.fetch(:filename, nil),
            platform: platform_name
          )
        end
      end

      # Parse Conan reference format:
      # name/version[@username[/channel]][#recipe_revision][:package_id[#package_revision]][%timestamp]
      def self.parse_conan_reference(ref)
        return [nil, nil] if ref.nil? || ref.empty? || !ref.include?("/")

        # Strip timestamp, package info, recipe revision, and user/channel
        ref = ref.split("%", 2)[0]
        ref = ref.split(":", 2)[0]
        ref = ref.split("#", 2)[0]
        ref = ref.split("@", 2)[0]

        parts = ref.split("/", 2)
        [parts[0], parts[1]]
      end
    end
  end
end
