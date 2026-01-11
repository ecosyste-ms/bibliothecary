# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Deno do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("deno")
  end

  it "parses dependencies from deno.json" do
    expect(described_class.analyse_contents("deno.json", load_fixture("deno.json"))).to eq({
      platform: "deno",
      path: "deno.json",
      project_name: nil,
      dependencies: [
        Bibliothecary::Dependency.new(platform: "deno", name: "chalk", requirement: "5.3.0", type: "runtime", source: "deno.json"),
        Bibliothecary::Dependency.new(platform: "deno", name: "lodash", requirement: "*", type: "runtime", source: "deno.json"),
        Bibliothecary::Dependency.new(platform: "deno", name: "@std/path", requirement: "^1.0.0", type: "runtime", source: "deno.json"),
        Bibliothecary::Dependency.new(platform: "deno", name: "@std/fs", requirement: "*", type: "runtime", source: "deno.json"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "parses dependencies from deno.lock" do
    expect(described_class.analyse_contents("deno.lock", load_fixture("deno.lock"))).to eq({
      platform: "deno",
      path: "deno.lock",
      project_name: nil,
      dependencies: [
        Bibliothecary::Dependency.new(platform: "deno", name: "@std/fs", requirement: "1.0.3", type: "runtime", source: "deno.lock", integrity: "sha256-abc123"),
        Bibliothecary::Dependency.new(platform: "deno", name: "@std/path", requirement: "1.0.6", type: "runtime", source: "deno.lock", integrity: "sha256-def456"),
        Bibliothecary::Dependency.new(platform: "deno", name: "chalk", requirement: "5.3.0", type: "runtime", source: "deno.lock", integrity: "sha512-xyz789"),
        Bibliothecary::Dependency.new(platform: "deno", name: "lodash", requirement: "4.17.21", type: "runtime", source: "deno.lock", integrity: "sha512-uvw012"),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("deno.json")).to be_truthy
    expect(described_class.match?("deno.jsonc")).to be_truthy
    expect(described_class.match?("deno.lock")).to be_truthy
  end

  describe ".parse_specifier" do
    it "parses npm specifiers with version" do
      expect(described_class.parse_specifier("npm:chalk@5.3.0")).to eq(["chalk", "5.3.0"])
    end

    it "parses npm specifiers without version" do
      expect(described_class.parse_specifier("npm:chalk")).to eq(["chalk", "*"])
    end

    it "parses jsr specifiers with version" do
      expect(described_class.parse_specifier("jsr:@std/path@^1.0.0")).to eq(["@std/path", "^1.0.0"])
    end

    it "parses jsr specifiers without version" do
      expect(described_class.parse_specifier("jsr:@std/path")).to eq(["@std/path", "*"])
    end

    it "returns nil for unsupported protocols" do
      expect(described_class.parse_specifier("https://example.com/mod.ts")).to be_nil
    end
  end
end
