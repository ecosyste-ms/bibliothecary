# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    class Nix
      include Bibliothecary::Analyser

      def self.file_patterns
        [
          "flake.nix",
          "flake.lock",
          "nix/sources.json",
          "npins/sources.json",
        ]
      end

      def self.mapping
        {
          match_filename("flake.nix") => {
            kind: "manifest",
            parser: :parse_flake_nix,
          },
          match_filename("flake.lock") => {
            kind: "lockfile",
            parser: :parse_flake_lock,
          },
          match_filename("nix/sources.json") => {
            kind: "lockfile",
            parser: :parse_niv_sources,
          },
          match_filename("npins/sources.json") => {
            kind: "lockfile",
            parser: :parse_npins_sources,
          },
        }
      end

      # Parse flake.nix manifest file
      # Extracts inputs from the Nix expression using regex
      def self.parse_flake_nix(file_contents, options: {})
        source = options.fetch(:filename, nil)
        dependencies = []

        # Pattern 1: name.url = "...";
        # e.g., nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        file_contents.scan(/^\s*([\w][\w-]*)\.url\s*=\s*"([^"]+)"/) do |name, url|
          requirement = parse_flake_url(url)
          dependencies << Dependency.new(
            name: name,
            requirement: requirement,
            type: "runtime",
            source: source,
            platform: platform_name
          )
        end

        # Pattern 2: name = { url = "..."; ... };
        # e.g., home-manager = { url = "github:nix-community/home-manager"; };
        file_contents.scan(/^\s*([\w][\w-]*)\s*=\s*\{\s*\n?\s*url\s*=\s*"([^"]+)"/) do |name, url|
          requirement = parse_flake_url(url)
          dependencies << Dependency.new(
            name: name,
            requirement: requirement,
            type: "runtime",
            source: source,
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      # Parse flake.lock lockfile
      def self.parse_flake_lock(file_contents, options: {})
        source = options.fetch(:filename, nil)
        lock = JSON.parse(file_contents)
        dependencies = []

        nodes = lock.fetch("nodes", {})
        root_node = nodes.fetch("root", {})
        root_inputs = root_node.fetch("inputs", {})

        root_inputs.each do |name, node_key|
          # node_key can be a string or an array (for follows)
          node_key = node_key.first if node_key.is_a?(Array)
          node = nodes[node_key]
          next unless node

          locked = node.fetch("locked", {})
          requirement = format_locked_version(locked)

          dependencies << Dependency.new(
            name: name,
            requirement: requirement,
            type: "runtime",
            source: source,
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      # Parse niv sources.json lockfile
      def self.parse_niv_sources(file_contents, options: {})
        source = options.fetch(:filename, nil)
        sources = JSON.parse(file_contents)
        dependencies = []

        sources.each do |name, attrs|
          next unless attrs.is_a?(Hash)

          requirement = format_niv_version(attrs)

          dependencies << Dependency.new(
            name: name,
            requirement: requirement,
            type: "runtime",
            source: source,
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      # Parse npins sources.json lockfile
      def self.parse_npins_sources(file_contents, options: {})
        source = options.fetch(:filename, nil)
        data = JSON.parse(file_contents)
        dependencies = []

        pins = data.fetch("pins", {})

        pins.each do |name, attrs|
          next unless attrs.is_a?(Hash)

          requirement = format_npins_version(attrs)

          dependencies << Dependency.new(
            name: name,
            requirement: requirement,
            type: "runtime",
            source: source,
            platform: platform_name
          )
        end

        ParserResult.new(dependencies: dependencies)
      end

      # Parse a flake URL into a version/requirement string
      # Examples:
      #   "github:NixOS/nixpkgs/nixos-unstable" => "nixos-unstable"
      #   "github:NixOS/nixpkgs" => "*"
      #   "git+https://github.com/foo/bar?ref=v1.0" => "v1.0"
      def self.parse_flake_url(url)
        case url
        when /^github:([^\/]+)\/([^\/\?]+)(?:\/([^\?]+))?/
          $3 || "*"
        when /^gitlab:([^\/]+)\/([^\/\?]+)(?:\/([^\?]+))?/
          $3 || "*"
        when /\?ref=([^&]+)/
          $1
        when /\?rev=([^&]+)/
          $1
        else
          "*"
        end
      end

      # Format locked version from flake.lock node
      def self.format_locked_version(locked)
        rev = locked["rev"]
        return rev[0..6] if rev # Short commit hash

        locked["version"] || "*"
      end

      # Format version from niv sources.json entry
      def self.format_niv_version(attrs)
        if attrs["rev"]
          attrs["rev"][0..6]
        elsif attrs["version"]
          attrs["version"]
        else
          "*"
        end
      end

      # Format version from npins sources.json entry
      def self.format_npins_version(attrs)
        if attrs["revision"]
          attrs["revision"][0..6]
        elsif attrs["version"]
          attrs["version"]
        else
          "*"
        end
      end
    end
  end
end
