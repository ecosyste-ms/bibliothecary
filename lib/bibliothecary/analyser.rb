# frozen_string_literal: true

require_relative "analyser/matchers"
require_relative "analyser/determinations"
require_relative "analyser/analysis"

module Bibliothecary
  module Analyser
    def self.create_error_analysis(platform_name, relative_path, kind, message, location = nil)
      {
        platform: platform_name,
        path: relative_path,
        dependencies: nil,
        kind: kind,
        success: false,
        error_message: message,
        error_location: location,
      }
    end

    def self.create_analysis(platform_name, relative_path, kind, parser_result)
      {
        platform: platform_name,
        path: relative_path,
        project_name: parser_result.project_name,
        dependencies: parser_result.dependencies,
        kind: kind,
        success: true,
      }
    end

    def self.included(base)
      base.extend(ClassMethods)

      # Group like-methods into separate modules for easier comprehension.
      base.extend(Bibliothecary::Analyser::Matchers)
      base.extend(Bibliothecary::Analyser::Determinations)
      base.extend(Bibliothecary::Analyser::Analysis)
    end

    module ClassMethods
      def platform_name
        @platform_name ||= name.to_s.split("::").last.downcase.freeze
      end

      def map_dependencies(hash, key, type, source = nil)
        hash.fetch(key, []).map do |name, requirement|
          Dependency.new(
            platform: platform_name,
            name: name,
            requirement: requirement,
            type: type,
            source: source
          )
        end
      end
    end
  end
end
