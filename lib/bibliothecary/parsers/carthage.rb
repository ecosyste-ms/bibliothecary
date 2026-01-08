module Bibliothecary
  module Parsers
    class Carthage
      include Bibliothecary::Analyser

      # Matches Cartfile entries:
      # github "owner/repo" >= 1.0
      # github "owner/repo" "branch"
      # github "owner/repo"
      # git "url" "ref"
      # binary "url" >= 1.0
      # Group 1: source type (github, git, binary)
      # Group 2: identifier (owner/repo or URL)
      # Group 3: quoted version/branch
      # Group 4: unquoted requirement (e.g., >= 1.0, ~> 2.0)
      CARTFILE_REGEXP = /^(github|git|binary)\s+"([^"]+)"(?:\s+(?:"([^"]+)"|((?:>=|<=|~>|==|>|<)\s*[\d.]+)))?/

      def self.file_patterns
        ["Cartfile", "Cartfile.private", "Cartfile.resolved"]
      end

      def self.mapping
        {
          match_filename("Cartfile") => {
            kind: "manifest",
            parser: :parse_cartfile,
          },
          match_filename("Cartfile.private") => {
            kind: "manifest",
            parser: :parse_cartfile_private,
          },
          match_filename("Cartfile.resolved") => {
            kind: "lockfile",
            parser: :parse_cartfile_resolved,
          },
        }
      end


      def self.parse_cartfile(file_contents, options: {})
        parse_cartfile_contents(file_contents, options.fetch(:filename, "Cartfile"), "runtime")
      end

      def self.parse_cartfile_private(file_contents, options: {})
        parse_cartfile_contents(file_contents, options.fetch(:filename, "Cartfile.private"), "development")
      end

      def self.parse_cartfile_resolved(file_contents, options: {})
        parse_cartfile_contents(file_contents, options.fetch(:filename, "Cartfile.resolved"), "runtime")
      end

      def self.parse_cartfile_contents(contents, source, type)
        deps = []

        contents.each_line do |line|
          # Remove inline comments
          line = line.sub(/#.*$/, "").strip
          next if line.empty?

          match = line.match(CARTFILE_REGEXP)
          next unless match

          source_type = match[1]  # github, git, or binary
          identifier = match[2]   # owner/repo or URL
          # match[3] is quoted version/branch, match[4] is unquoted requirement
          version = match[3] || match[4] || "*"

          # For github sources, use identifier as-is (could be owner/repo or full URL)
          # For git/binary sources, extract repo name from URL
          name = case source_type
                 when "github"
                   # Could be "owner/repo" or a full URL like "https://enterprise.local/..."
                   if identifier.include?("://")
                     identifier.split("/").last&.sub(/\.git$/, "") || identifier
                   else
                     identifier
                   end
                 else
                   # Extract name from URL (last path component without .git)
                   identifier.split("/").last&.sub(/\.git$/, "") || identifier
                 end

          deps << Dependency.new(
            platform: platform_name,
            name: name,
            requirement: version,
            type: type,
            source: source
          )
        end

        ParserResult.new(dependencies: deps)
      end
    end
  end
end
