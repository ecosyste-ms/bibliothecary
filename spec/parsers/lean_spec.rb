# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Lean do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("lean")
  end

  it "parses dependencies from lakefile.toml" do
    expect(described_class.analyse_contents("lakefile.toml", load_fixture("lean/lakefile.toml"))).to eq({
      platform: "lean",
      path: "lakefile.toml",
      project_name: "example",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "lean", name: "leanprover-community/batteries", requirement: "v4.30.0-rc2", type: "runtime", direct: true, source: "lakefile.toml"),
        Bibliothecary::Dependency.new(platform: "lean", name: "Cli", requirement: "main", type: "runtime", direct: true, source: "lakefile.toml"),
        Bibliothecary::Dependency.new(platform: "lean", name: "leanprover-community/mathlib", requirement: "4.30.0", type: "runtime", direct: true, source: "lakefile.toml"),
        Bibliothecary::Dependency.new(platform: "lean", name: "leansqlite", requirement: "v0.1.0", type: "runtime", direct: true, source: "lakefile.toml"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "parses dependencies from lakefile.lean" do
    expect(described_class.analyse_contents("lakefile.lean", load_fixture("lean/lakefile.lean"))).to eq({
      platform: "lean",
      path: "lakefile.lean",
      project_name: nil,
      dependencies: [
        Bibliothecary::Dependency.new(platform: "lean", name: "leanprover-community/batteries", requirement: "v4.30.0-rc2", type: "runtime", direct: true, source: "lakefile.lean"),
        Bibliothecary::Dependency.new(platform: "lean", name: "leanprover-community/aesop", requirement: "4.30.0", type: "runtime", direct: true, source: "lakefile.lean"),
        Bibliothecary::Dependency.new(platform: "lean", name: "MD4Lean", requirement: "main", type: "runtime", direct: true, source: "lakefile.lean"),
        Bibliothecary::Dependency.new(platform: "lean", name: "UnicodeBasic", requirement: "v1.0.0", type: "runtime", direct: true, source: "lakefile.lean"),
        Bibliothecary::Dependency.new(platform: "lean", name: "Cli", requirement: "*", type: "runtime", direct: true, source: "lakefile.lean"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "parses dependencies from lake-manifest.json" do
    expect(described_class.analyse_contents("lake-manifest.json", load_fixture("lean/lake-manifest.json"))).to eq({
      platform: "lean",
      path: "lake-manifest.json",
      project_name: "example",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "lean", name: "leanprover-community/batteries", requirement: "5c57f3857ba81924a88b2cdf4f062e34ec04ff11", type: "runtime", direct: true, source: "lake-manifest.json"),
        Bibliothecary::Dependency.new(platform: "lean", name: "Cli", requirement: "13567aed1ac4f12aea9484178e07e51f8c9f7658", type: "runtime", direct: true, source: "lake-manifest.json"),
        Bibliothecary::Dependency.new(platform: "lean", name: "plausible", requirement: "86210d4ad1b08b086d0bd638637a75246523dbb8", type: "runtime", direct: false, source: "lake-manifest.json"),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("lakefile.toml")).to be_truthy
    expect(described_class.match?("lakefile.lean")).to be_truthy
    expect(described_class.match?("lake-manifest.json")).to be_truthy
  end

  it "does not match other filepaths" do
    expect(described_class.match?("Lakefile")).to be_falsey
    expect(described_class.match?("manifest.json")).to be_falsey
  end
end
