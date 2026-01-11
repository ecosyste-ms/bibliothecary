# frozen_string_literal: true

require "json"

module Bibliothecary
  module Parsers
    class Packagist
      include Bibliothecary::Analyser

      def self.file_patterns
        ["composer.json", "composer.lock"]
      end

      def self.mapping
        {
          match_filename("composer.json") => {
            kind: "manifest",
            parser: :parse_manifest,
          },
          match_filename("composer.lock") => {
            kind: "lockfile",
            parser: :parse_lockfile,
          },
        }
      end


      def self.parse_lockfile(file_contents, options: {})
        manifest = JSON.parse file_contents
        source = options.fetch(:filename, nil)

        dependencies = manifest.fetch("packages", []).map do |dependency|
          parse_composer_dependency(dependency, "runtime", source)
        end + manifest.fetch("packages-dev", []).map do |dependency|
          parse_composer_dependency(dependency, "development", source)
        end
        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_composer_dependency(dependency, type, source)
        requirement = dependency["version"]
        original_requirement = nil

        # Store Drupal version if Drupal, but include the original manifest version for reference
        if drupal_module?(dependency)
          original_requirement = requirement
          requirement = dependency.dig("source", "reference")
        end

        # Extract shasum from dist if present and non-empty
        shasum = dependency.dig("dist", "shasum")
        integrity = shasum && !shasum.empty? ? "sha1=#{shasum}" : nil

        Dependency.new(
          name: dependency["name"],
          requirement: requirement,
          type: type,
          original_requirement: original_requirement,
          source: source,
          platform: platform_name,
          integrity: integrity
        )
      end

      def self.parse_manifest(file_contents, options: {})
        manifest = JSON.parse file_contents
        dependencies = map_dependencies(manifest, "require", "runtime", options.fetch(:filename, nil)) +
                       map_dependencies(manifest, "require-dev", "development", options.fetch(:filename, nil))
        ParserResult.new(dependencies: dependencies)
      end

      # Drupal hosts its own Composer repository, where its "modules" are indexed and searchable. The best way to
      # confirm that Drupal's repo is being used is if its in the "repositories" in composer.json
      # (https://support.acquia.com/hc/en-us/articles/360048081273-Using-Composer-to-manage-dependencies-in-Drupal-8-and-9),
      # but you may only have composer.lock, so we test if the type is "drupal-*" (e.g. "drupal-module" or "drupal-theme")
      # The Drupal team also setup its own mapper of Composer semver -> Drupal tool-specfic versions
      # (https://www.drupal.org/project/project_composer/issues/2622450),
      # so we return the Drupal requirement instead of semver requirement if it's here
      # (https://www.drupal.org/docs/develop/using-composer/using-composer-to-install-drupal-and-manage-dependencies#s-about-semantic-versioning)
      private_class_method def self.drupal_module?(dependency)
        dependency["type"] =~ /drupal/ && dependency.dig("source", "reference")
      end
    end
  end
end
