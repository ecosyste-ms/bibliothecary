# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Rubygems do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("rubygems")
  end

  it "parses dependencies from Gemfile" do
    expect(described_class.analyse_contents("Gemfile", load_fixture("Gemfile"))).to eq({
                                                                                         platform: "rubygems",
                                                                                         path: "Gemfile",
                                                                                         project_name: nil,
                                                                                         dependencies: [
        Bibliothecary::Dependency.new(platform: "rubygems", name: "oj", requirement: ">= 0", type: "runtime", source: "Gemfile"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "rails", requirement: "= 4.2.0", type: "runtime", source: "Gemfile"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "leveldb-ruby", requirement: "= 0.15", type: "runtime", source: "Gemfile"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "nokogiri", requirement: "~> 1.6", type: "runtime", source: "Gemfile"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "rack", requirement: ">= 2.0", type: "runtime", source: "Gemfile"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "json", requirement: "< 3.0", type: "runtime", source: "Gemfile"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "spring", requirement: ">= 0", type: "development", source: "Gemfile"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "thin", requirement: ">= 0", type: "development", source: "Gemfile"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "puma", requirement: ">= 0", type: "runtime", source: "Gemfile"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "rails_12factor", requirement: ">= 0", type: "runtime", source: "Gemfile"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "bugsnag", requirement: ">= 0", type: "runtime", source: "Gemfile"),
      ],
                                                                                         kind: "manifest",
                                                                                         success: true,
                                                                                       })
  end

  it "parses dependencies from gems.rb" do
    expect(described_class.analyse_contents("gems.rb", load_fixture("gems.rb"))).to eq({
                                                                                         platform: "rubygems",
                                                                                         path: "gems.rb",
                                                                                         project_name: nil,
                                                                                         dependencies: [
        Bibliothecary::Dependency.new(platform: "rubygems", name: "oj", requirement: ">= 0", type: "runtime", source: "gems.rb"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "rails", requirement: "= 4.2.0", type: "runtime", source: "gems.rb"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "leveldb-ruby", requirement: "= 0.15", type: "runtime", source: "gems.rb"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "nokogiri", requirement: "~> 1.6", type: "runtime", source: "gems.rb"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "rack", requirement: ">= 2.0", type: "runtime", source: "gems.rb"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "json", requirement: "< 3.0", type: "runtime", source: "gems.rb"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "spring", requirement: ">= 0", type: "development", source: "gems.rb"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "thin", requirement: ">= 0", type: "development", source: "gems.rb"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "puma", requirement: ">= 0", type: "runtime", source: "gems.rb"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "rails_12factor", requirement: ">= 0", type: "runtime", source: "gems.rb"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "bugsnag", requirement: ">= 0", type: "runtime", source: "gems.rb"),
      ],
                                                                                         kind: "manifest",
                                                                                         success: true,
                                                                                       })
  end

  it "parses dependencies from devise.gemspec" do
    expect(described_class.analyse_contents("devise.gemspec", load_fixture("devise.gemspec"))).to eq({
                                                                                                       platform: "rubygems",
                                                                                                       path: "devise.gemspec",
                                                                                                       project_name: nil,
                                                                                                       dependencies: [
        Bibliothecary::Dependency.new(platform: "rubygems", name: "warden", requirement: "~> 1.2.3", type: "runtime", source: "devise.gemspec"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "orm_adapter", requirement: "~> 0.1", type: "development", source: "devise.gemspec"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "bcrypt", requirement: "~> 3.0", type: "runtime", source: "devise.gemspec"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "thread_safe", requirement: "~> 0.1", type: "runtime", source: "devise.gemspec"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "railties", requirement: ">= 3.2.6, < 5", type: "runtime", source: "devise.gemspec"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "responders", requirement: ">= 0", type: "runtime", source: "devise.gemspec"),
      ],
                                                                                                       kind: "manifest",
                                                                                                       success: true,
                                                                                                     })
  end

  it "parses dependencies from Gemfile.lock" do
    expect(described_class.analyse_contents("Gemfile.lock", load_fixture("Gemfile.lock"))).to eq({
                                                                                                   platform: "rubygems",
                                                                                                   path: "Gemfile.lock",
                                                                                                   project_name: nil,
                                                                                                   dependencies: [
        Bibliothecary::Dependency.new(platform: "rubygems", name: "CFPropertyList", requirement: "2.3.1", type: "runtime", source: "Gemfile.lock"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "actionmailer", requirement: "4.2.3", type: "runtime", source: "Gemfile.lock"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "googleauth", requirement: "0.4.1", type: "runtime", source: "Gemfile.lock"),
        Bibliothecary::Dependency.new(platform: "rubygems", name: "hashie", requirement: "3.4.2", type: "runtime", source: "Gemfile.lock"),
      ],
                                                                                                   kind: "lockfile",
                                                                                                   success: true,
                                                                                                 })
  end

  it "parses bundler version from Gemfile.lock" do
    result = described_class.analyse_contents("Gemfile.lock", load_fixture("GemfileWithBundler.lock"))
    expect(result).to include(
      platform: "rubygems",
      path: "Gemfile.lock",
      kind: "lockfile",
      project_name: nil,
      success: true
    )

    expect(result[:dependencies]).to include(Bibliothecary::Dependency.new(platform: "rubygems", name: "bundler", requirement: "2.3.19", type: "runtime", source: "Gemfile.lock"))
  end

  it "parses checksums from Gemfile.lock with CHECKSUMS section" do
    result = described_class.analyse_contents("Gemfile.lock", load_fixture("Gemfile-with-checksums.lock"))
    expect(result).to include(
      platform: "rubygems",
      path: "Gemfile.lock",
      kind: "lockfile",
      project_name: nil,
      success: true
    )

    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(platform: "rubygems", name: "builder", requirement: "3.3.0", type: "runtime", source: "Gemfile.lock", integrity: "sha256=497918d2f9dca528fdca4b88d84e4ef4387256d984b8154e9d5d3fe5a9c8835f"),
      Bibliothecary::Dependency.new(platform: "rubygems", name: "rake", requirement: "13.2.1", type: "runtime", source: "Gemfile.lock", integrity: "sha256=46cb38dae65d7d74b6020a4ac9d48afed8eb8149c040eccf0523bec91907059d"),
      Bibliothecary::Dependency.new(platform: "rubygems", name: "bundler", requirement: "2.6.2", type: "runtime", source: "Gemfile.lock", integrity: "sha256=9e0c09d351d7b8bc1ceb11a15d8ca6f3dc6cbecc77ae99e27c3ec8b656f7f5ca")
    )
  end

  it "parses dependencies from Gemfile.lock with windows line endings" do
    fixture = load_fixture("GemfileLineEndings.lock")
    # If this fails, the line endings changed, on this file.
    # to fix it, run `vim spec/fixtures/GemfileLineEndings.lock +"set ff=dos" +wq`
    expect(fixture).to include("\r\n")

    expect(
      described_class.analyse_contents("Gemfile.lock", fixture)
    ).to eq({
              platform: "rubygems",
              path: "Gemfile.lock",
              dependencies: [
          Bibliothecary::Dependency.new(platform: "rubygems", name: "rails", requirement: "5.2.3", type: "runtime", source: "Gemfile.lock"),
        ],
              kind: "lockfile",
              project_name: nil,
              success: true,
            })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("devise.gemspec")).to be_truthy
    expect(described_class.match?("Gemfile")).to be_truthy
    expect(described_class.match?("Gemfile.lock")).to be_truthy
    expect(described_class.match?("gems.rb")).to be_truthy
    expect(described_class.match?("gems.locked")).to be_truthy
  end
end
