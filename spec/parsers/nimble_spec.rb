# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Nimble do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("nimble")
  end

  it "parses dependencies from .nimble files" do
    expect(described_class.analyse_contents("example.nimble", load_fixture("example.nimble"))).to eq({
      platform: "nimble",
      path: "example.nimble",
      project_name: nil,
      dependencies: [
        Bibliothecary::Dependency.new(platform: "nimble", name: "nim", requirement: ">= 1.6.0", type: "runtime", source: "example.nimble"),
        Bibliothecary::Dependency.new(platform: "nimble", name: "chronos", requirement: ">= 3.0.0", type: "runtime", source: "example.nimble"),
        Bibliothecary::Dependency.new(platform: "nimble", name: "chronicles", requirement: ">= 0.10.0", type: "runtime", source: "example.nimble"),
        Bibliothecary::Dependency.new(platform: "nimble", name: "stew", requirement: ">= 0.1.0", type: "runtime", source: "example.nimble"),
        Bibliothecary::Dependency.new(platform: "nimble", name: "results", requirement: "*", type: "runtime", source: "example.nimble"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("example.nimble")).to be_truthy
    expect(described_class.match?("mypackage.nimble")).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?("package.json")).to be_falsey
    expect(described_class.match?("nimble.lock")).to be_falsey
  end
end
