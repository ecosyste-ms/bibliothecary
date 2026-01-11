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

    cowboy = deps.find { |d| d.name == "cowboy" }
    expect(cowboy.requirement).to eq("1.0.4")
    expect(cowboy.integrity).to eq("sha256=a324a8df9f2316c833a470d918aaf73ae894278b8aa6226ce7a9bf699388f878")

    ranch = deps.find { |d| d.name == "ranch" }
    expect(ranch.requirement).to eq("1.2.1")
    expect(ranch.integrity).to eq("sha256=a6fb992c10f2187b46ffd17ce398ddf8a54f691b81768f9ef5f461ea7e28c762")
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
        Bibliothecary::Dependency.new(platform: "hex", name: "gleam_stdlib", requirement: "0.60.0", type: "runtime", source: "manifest.toml", integrity: "sha256=621d600bb134bc239cb2537630899817b1a42e60a1d46c5e9f3fae39f88c800b"),
        Bibliothecary::Dependency.new(platform: "hex", name: "gleam_http", requirement: "3.7.0", type: "runtime", source: "manifest.toml", integrity: "sha256=ea8e8b91de4d2c3d85b9e4e034ec7ce81e7c552e6e1ecf755c399037df173208"),
        Bibliothecary::Dependency.new(platform: "hex", name: "gleeunit", requirement: "1.5.1", type: "runtime", source: "manifest.toml", integrity: "sha256=d33b7736cf0766ed3065f64a1ebb351e72b2e8de39bafc8ada0e35e92a6a934f"),
      ],
      kind: "lockfile",
      project_name: nil,
      success: true,
    })
  end

  it "parses dependencies from rebar.lock" do
    expect(described_class.analyse_contents("rebar.lock", load_fixture("rebar.lock"))).to eq({
      platform: "hex",
      path: "rebar.lock",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "hex", name: "hex_core", requirement: "0.10.3", type: "runtime", source: "rebar.lock", integrity: "sha256=21e84b3ab21eee6a1eaa56b69624e0d7d82f61f148b4c7441b4692fa2c48e0c1"),
        Bibliothecary::Dependency.new(platform: "hex", name: "verl", requirement: "1.1.1", type: "runtime", source: "rebar.lock", integrity: "sha256=0925f3708b11cacc6fba2cb35b5efdce78c6e79b9db90a30bd75a3c6fe58a8a5"),
        Bibliothecary::Dependency.new(platform: "hex", name: "ssl_verify_fun", requirement: "1.1.7", type: "runtime", source: "rebar.lock", integrity: "sha256=fe4c190e8f37401d30167c8c405eda19469f34577987c76dde613e838bbc67f8"),
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
    expect(described_class.match?("rebar.lock")).to be_truthy
  end

  it "matches manifest.toml with Gleam content" do
    expect(described_class.match?("manifest.toml", load_fixture("manifest.toml"))).to be_truthy
  end

  it "does not match manifest.toml without Gleam header" do
    expect(described_class.match?("manifest.toml", "packages = []")).to be_falsey
  end
end
