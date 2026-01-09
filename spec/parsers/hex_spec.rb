require "spec_helper"

describe Bibliothecary::Parsers::Hex do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("hex")
  end

  it "parses dependencies from mix.exs" do
    expect(described_class.analyse_contents("mix.exs", load_fixture("mix.exs"))).to eq({
      platform: "hex",
      path: "mix.exs",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "hex", name: "poison", requirement: "~> 1.3.1", type: "runtime", source: "mix.exs"),
        Bibliothecary::Dependency.new(platform: "hex", name: "plug", requirement: "~> 0.11.0", type: "runtime", source: "mix.exs"),
        Bibliothecary::Dependency.new(platform: "hex", name: "cowboy", requirement: "~> 1.0.0", type: "runtime", source: "mix.exs"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "parses dependencies from mix.lock" do
    result = described_class.analyse_contents("mix.lock", load_fixture("mix.lock"))
    expect(result[:platform]).to eq("hex")
    expect(result[:path]).to eq("mix.lock")
    expect(result[:kind]).to eq("lockfile")
    expect(result[:success]).to eq(true)

    # Check all deps are present (order may vary)
    deps = result[:dependencies]
    expect(deps.length).to eq(5)
    expect(deps.map(&:name)).to match_array(%w[cowboy cowlib plug poison ranch])
    expect(deps.find { |d| d.name == "cowboy" }.requirement).to eq("1.0.4")
    expect(deps.find { |d| d.name == "ranch" }.requirement).to eq("1.2.1")
  end

  it "parses dependencies from gleam.toml" do
    expect(described_class.analyse_contents("gleam.toml", load_fixture("gleam.toml"))).to eq({
      platform: "hex",
      path: "gleam.toml",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "hex", name: "gleam_stdlib", requirement: ">= 0.53.0 and < 2.0.0", type: "runtime", source: "gleam.toml"),
        Bibliothecary::Dependency.new(platform: "hex", name: "gleam_http", requirement: "~> 3.0", type: "runtime", source: "gleam.toml"),
        Bibliothecary::Dependency.new(platform: "hex", name: "gleeunit", requirement: ">= 1.3.0 and < 2.0.0", type: "development", source: "gleam.toml"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "parses dependencies from manifest.toml (Gleam lockfile)" do
    expect(described_class.analyse_contents("manifest.toml", load_fixture("manifest.toml"))).to eq({
      platform: "hex",
      path: "manifest.toml",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "hex", name: "gleam_stdlib", requirement: "0.60.0", type: "runtime", source: "manifest.toml"),
        Bibliothecary::Dependency.new(platform: "hex", name: "gleam_http", requirement: "3.7.0", type: "runtime", source: "manifest.toml"),
        Bibliothecary::Dependency.new(platform: "hex", name: "gleeunit", requirement: "1.5.1", type: "runtime", source: "manifest.toml"),
      ],
      kind: "lockfile",
      project_name: nil,
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("mix.exs")).to be_truthy
    expect(described_class.match?("mix.lock")).to be_truthy
    expect(described_class.match?("gleam.toml")).to be_truthy
  end

  it "matches manifest.toml with Gleam content" do
    expect(described_class.match?("manifest.toml", load_fixture("manifest.toml"))).to be_truthy
  end

  it "does not match manifest.toml without Gleam header" do
    expect(described_class.match?("manifest.toml", "packages = []")).to be_falsey
  end
end
