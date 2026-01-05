module Bibliothecary
  module Parsers
    class Vcpkg
      include Bibliothecary::Analyser

      def self.mapping
        {
          match_filename("vcpkg.json", case_insensitive: true) => {
            kind: "manifest",
            parser: :parse_vcpkg_json,
          },
          match_filename("_generated-vcpkg-list.json") => {
            kind: "lockfile",
            parser: :parse_vcpkg_list_json,
          },
        }
      end

      add_multi_parser(Bibliothecary::MultiParsers::DependenciesCSV)

      def self.parse_vcpkg_json(file_contents, options: {})
        source = options.fetch(:filename, nil)
        json = JSON.parse(file_contents)
        deps = json["dependencies"] || []
        return ParserResult.new(dependencies: []) if deps.empty?

        overrides = {}
        json["overrides"]&.each do |override|
          next unless override.is_a?(Hash) && override["name"]

          version = override["version"] || override["version-semver"] || override["version-date"] || override["version-string"]
          overrides[override["name"]] = format_requirement(version, override["port-version"])
        end

        dependencies = deps.map do |dependency|
          if dependency.is_a?(String)
            name = dependency
            requirement = nil
            is_dev = false
          else
            name = dependency["name"]
            requirement = dependency["version>="] ? ">=#{dependency['version>=']}" : nil
            is_dev = dependency["host"] == true
          end

          next if name.nil? || name.empty?

          requirement = overrides[name] if overrides[name]

          Dependency.new(
            platform: platform_name,
            name: name,
            requirement: requirement || "*",
            type: is_dev ? "development" : "runtime",
            source: source
          )
        end.compact.uniq

        ParserResult.new(dependencies: dependencies)
      end

      def self.parse_vcpkg_list_json(file_contents, options: {})
        source = options.fetch(:filename, nil)
        json = JSON.parse(file_contents)

        dependencies = json.values.map do |package_info|
          name = package_info["package_name"]
          next if name.nil? || name.empty?

          Dependency.new(
            platform: platform_name,
            name: name,
            requirement: format_requirement(package_info["version"], package_info["port_version"]),
            type: "runtime",
            source: source
          )
        end.compact

        ParserResult.new(dependencies: dependencies)
      end

      def self.format_requirement(version, port_version)
        return "*" unless version

        if port_version && port_version > 0
          "#{version}##{port_version}"
        else
          version
        end
      end
    end
  end
end
