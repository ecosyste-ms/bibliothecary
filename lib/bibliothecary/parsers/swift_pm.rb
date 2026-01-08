require "json"

module Bibliothecary
  module Parsers
    class SwiftPM
      include Bibliothecary::Analyser

      # Matches .Package(url: "...", majorVersion: X, minor: Y)
      # Also matches .package(url: "...", from: "X.Y.Z") (Swift 4+)
      PACKAGE_REGEXP_LEGACY = /\.Package\s*\(\s*url:\s*"([^"]+)"[^)]*majorVersion:\s*(\d+)[^)]*minor:\s*(\d+)/
      PACKAGE_REGEXP_FROM = /\.package\s*\(\s*(?:name:\s*"[^"]+",\s*)?url:\s*"([^"]+)"[^)]*from:\s*"([^"]+)"/i
      PACKAGE_REGEXP_EXACT = /\.package\s*\(\s*(?:name:\s*"[^"]+",\s*)?url:\s*"([^"]+)"[^)]*(?:\.exact|exact)\s*\(\s*"([^"]+)"\s*\)/i
      PACKAGE_REGEXP_RANGE = /\.package\s*\(\s*(?:name:\s*"[^"]+",\s*)?url:\s*"([^"]+)"[^)]*"([^"]+)"\s*(?:\.\.|\.\.\.)\s*"([^"]+)"/i

      def self.file_patterns
        ["Package.swift", "Package.resolved"]
      end

      def self.mapping
        {
          match_filename("Package.swift", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_package_swift,
            related_to: ["lockfile"],
          },
          match_filename("Package.resolved", case_insensitive: true) => {
            kind: "lockfile",
            parser: :parse_package_resolved,
            related_to: ["manifest"],
          },
        }
      end


      def self.parse_package_swift(file_contents, options: {})
        source = options.fetch(:filename, "Package.swift")
        deps = []

        # Remove comments (but not :// in URLs)
        content = file_contents.gsub(%r{(?<!:)//.*$}, "")

        # Legacy format: .Package(url: "...", majorVersion: X, minor: Y)
        content.scan(PACKAGE_REGEXP_LEGACY) do |url, major, minor|
          name = url.gsub(%r{^https?://}, "").gsub(/\.git$/, "")
          # Match the remote parser format: lowerBound - upperBound
          lower = "#{major}.#{minor}.0"
          upper = "#{major}.#{minor}.9223372036854775807"
          deps << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: "#{lower} - #{upper}",
            type: "runtime",
            source: source
          )
        end

        # Swift 4+ format: .package(url: "...", from: "X.Y.Z")
        content.scan(PACKAGE_REGEXP_FROM) do |url, version|
          name = url.gsub(%r{^https?://}, "").gsub(/\.git$/, "")
          deps << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: ">= #{version}",
            type: "runtime",
            source: source
          )
        end

        # Swift 4+ exact version: .package(url: "...", .exact("X.Y.Z"))
        content.scan(PACKAGE_REGEXP_EXACT) do |url, version|
          name = url.gsub(%r{^https?://}, "").gsub(/\.git$/, "")
          deps << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: "= #{version}",
            type: "runtime",
            source: source
          )
        end

        # Swift 4+ range: .package(url: "...", "1.0.0"..<"2.0.0")
        content.scan(PACKAGE_REGEXP_RANGE) do |url, lower, upper|
          name = url.gsub(%r{^https?://}, "").gsub(/\.git$/, "")
          deps << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: "#{lower} - #{upper}",
            type: "runtime",
            source: source
          )
        end

        ParserResult.new(dependencies: deps)
      end

      def self.parse_package_resolved(file_contents, options: {})
        source = options.fetch(:filename, "Package.resolved")
        json = JSON.parse(file_contents)
        deps = if json["version"] == 1
          json["object"]["pins"].map do |dependency|
            name = dependency["repositoryURL"].gsub(%r{^https?://}, "").gsub(/\.git$/, "")
            version = dependency["state"]["version"]
            Dependency.new(
              platform: platform_name,
              name: name,
              requirement: version,
              type: "runtime",
              source: source
            )
          end
        else # version 2+
          json["pins"].map do |dependency|
            name = dependency["location"].gsub(%r{^https?://}, "").gsub(/\.git$/, "")
            version = dependency["state"]["version"]
            Dependency.new(
              platform: platform_name,
              name: name,
              requirement: version,
              type: "runtime",
              source: source
            )
          end
        end
        ParserResult.new(dependencies: deps)
      end
    end
  end
end
