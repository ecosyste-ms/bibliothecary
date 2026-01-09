# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Julia do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("julia")
  end

  it "parses dependencies from REQUIRE" do
    expect(described_class.analyse_contents("REQUIRE", load_fixture("REQUIRE"))).to eq({
                                                                                         platform: "julia",
                                                                                         path: "REQUIRE",
                                                                                         project_name: nil,
                                                                                         dependencies: [
        Bibliothecary::Dependency.new(platform: "julia", name: "julia", requirement: "0.3", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Codecs", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Colors", requirement: "0.3.4", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Compat", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Compose", requirement: "0.3.11", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Contour", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "DataFrames", requirement: "0.4.2", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "DataStructures", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Dates", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Distributions", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Gadfly", requirement: "0.7-", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Hexagons", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Homebrew", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Iterators", requirement: "0.1.5", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "JSON", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "KernelDensity", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Loess", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Plots", requirement: "0.12 0.15", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Showoff", requirement: "0.0.3", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "StatsBase", requirement: "*", type: "runtime", source: "REQUIRE"),
        Bibliothecary::Dependency.new(platform: "julia", name: "WinReg", requirement: "*", type: "runtime", source: "REQUIRE"),
      ],
                                                                                         kind: "manifest",
                                                                                         success: true,
                                                                                       })
  end

  it "parses dependencies from Project.toml" do
    expect(described_class.analyse_contents("Project.toml", load_fixture("julia/Project.toml"))).to eq({
      platform: "julia",
      path: "Project.toml",
      project_name: nil,
      dependencies: [
        Bibliothecary::Dependency.new(platform: "julia", name: "JSON", requirement: "*", type: "runtime", source: "Project.toml"),
        Bibliothecary::Dependency.new(platform: "julia", name: "HTTP", requirement: "*", type: "runtime", source: "Project.toml"),
        Bibliothecary::Dependency.new(platform: "julia", name: "Dates", requirement: "*", type: "runtime", source: "Project.toml"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "parses dependencies from Manifest.toml" do
    expect(described_class.analyse_contents("Manifest.toml", load_fixture("julia/Manifest.toml"))).to eq({
      platform: "julia",
      path: "Manifest.toml",
      project_name: nil,
      dependencies: [
        Bibliothecary::Dependency.new(platform: "julia", name: "Dates", requirement: "1.11.0", type: "runtime", source: "Manifest.toml"),
        Bibliothecary::Dependency.new(platform: "julia", name: "HTTP", requirement: "1.5.0", type: "runtime", source: "Manifest.toml"),
        Bibliothecary::Dependency.new(platform: "julia", name: "JSON", requirement: "0.21.4", type: "runtime", source: "Manifest.toml"),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("REQUIRE")).to be_truthy
    expect(described_class.match?("Project.toml")).to be_truthy
    expect(described_class.match?("Manifest.toml")).to be_truthy
  end
end
