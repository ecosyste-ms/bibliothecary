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

  it "matches valid manifest filepaths" do
    expect(described_class.match?("mix.exs")).to be_truthy
    expect(described_class.match?("mix.lock")).to be_truthy
  end
end
