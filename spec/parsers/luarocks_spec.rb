# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::LuaRocks do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("luarocks")
  end

  it "parses dependencies from .rockspec files" do
    expect(described_class.analyse_contents("example.rockspec", load_fixture("example.rockspec"))).to eq({
      platform: "luarocks",
      path: "example.rockspec",
      project_name: nil,
      dependencies: [
        Bibliothecary::Dependency.new(platform: "luarocks", name: "lua", requirement: ">= 5.1", type: "runtime", source: "example.rockspec"),
        Bibliothecary::Dependency.new(platform: "luarocks", name: "luafilesystem", requirement: ">= 1.8.0", type: "runtime", source: "example.rockspec"),
        Bibliothecary::Dependency.new(platform: "luarocks", name: "lpeg", requirement: "~> 1.0", type: "runtime", source: "example.rockspec"),
        Bibliothecary::Dependency.new(platform: "luarocks", name: "luasocket", requirement: "*", type: "runtime", source: "example.rockspec"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("example.rockspec")).to be_truthy
    expect(described_class.match?("mypackage-1.0.0-1.rockspec")).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?("package.json")).to be_falsey
    expect(described_class.match?("rocks.lock")).to be_falsey
  end
end
