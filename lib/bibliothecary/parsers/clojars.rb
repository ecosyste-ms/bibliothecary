module Bibliothecary
  module Parsers
    class Clojars
      include Bibliothecary::Analyser

      # Matches individual dependency: [name "version"]
      # Name can be like: org.clojure/clojure, cheshire, ring/ring-defaults
      DEPENDENCY_REGEXP = %r{\[([a-zA-Z0-9_./\-]+)\s+"([^"]+)"\]}

      def self.mapping
        {
          match_filename("project.clj") => {
            kind: "manifest",
            parser: :parse_manifest,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::CycloneDX)
      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_manifest(file_contents, options: {})
        source = options.fetch(:filename, "project.clj")
        deps = []

        # Find the :dependencies section and extract deps
        # Look for :dependencies followed by a vector of vectors
        if (deps_section = file_contents[/:dependencies\s*\[.*?\]\]/m])
          deps_section.scan(DEPENDENCY_REGEXP) do |name, version|
            deps << Dependency.new(
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
