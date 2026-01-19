module Bibliothecary
  module Parsers
    class Bazel
      include Bibliothecary::Analyser

      BAZEL_DEP_STATEMENT = %r{
        ^\s*bazel_dep\s*
        (?<bal>
          \(
            (?:
              [^()"'\\]+
              | "(?:\\.|[^"\\])*"
              | '(?:\\.|[^'\\])*'
              | \\ .
              | \g<bal>
            )*
          \)
        )
      }mx

      # key/value extraction inside the call
      DEPENDENCY_NAME    = /(?:^|[,(]\s*)name\s*=\s*(?<quote>["'])(?<value>(?:\\.|(?!\k<quote>).)*)\k<quote>/m
      DEPENDENCY_VERSION = /(?:^|[,(]\s*)version\s*=\s*(?<quote>["'])(?<value>(?:\\.|(?!\k<quote>).)*)\k<quote>/m
      DEPENDENCY_TYPE     = /(?:^|[,(]\s*)dev_dependency\s*=\s*(?<value>True|False)\b/m


      def self.file_patterns
        ["MODULE.bazel"]
      end

      def self.mapping
        {
          match_filename("MODULE.bazel") => {
            kind: "manifest",
            parser: :parse_module_bazel,
          }
        }
      end

      def self.parse_module_bazel(file_contents, options: {})
        source = options.fetch(:filename, nil)

        dependencies = file_contents.scan(BAZEL_DEP_STATEMENT).map do |(statement)|
          name = statement.match(DEPENDENCY_NAME)[:value]
          parsed_version = statement.match(DEPENDENCY_VERSION)
          parsed_type = statement.match(DEPENDENCY_TYPE)
          version = parsed_version ? parsed_version[:value] : '*'
          type =
            if parsed_type && parsed_type[:value] == "True"
              "development"
            else
              "runtime"
            end

          Dependency.new(
            platform: platform_name,
            name: name,
            requirement: version,
            type: type,
            source: source,
          )
        end
        ParserResult.new(dependencies: dependencies)
      end
    end
  end
end
