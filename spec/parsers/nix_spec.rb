# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Nix do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("nix")
  end

  it "parses dependencies from flake.nix" do
    expect(described_class.analyse_contents("flake.nix", load_fixture("flake.nix"))).to eq({
      platform: "nix",
      path: "flake.nix",
      project_name: nil,
      dependencies: [
        Bibliothecary::Dependency.new(platform: "nix", name: "nixpkgs", requirement: "nixos-unstable", type: "runtime", source: "flake.nix"),
        Bibliothecary::Dependency.new(platform: "nix", name: "flake-utils", requirement: "*", type: "runtime", source: "flake.nix"),
        Bibliothecary::Dependency.new(platform: "nix", name: "home-manager", requirement: "release-23.11", type: "runtime", source: "flake.nix"),
      ],
      kind: "manifest",
      success: true,
    })
  end

  it "parses dependencies from flake.lock" do
    expect(described_class.analyse_contents("flake.lock", load_fixture("flake.lock"))).to eq({
      platform: "nix",
      path: "flake.lock",
      project_name: nil,
      dependencies: [
        Bibliothecary::Dependency.new(platform: "nix", name: "flake-utils", requirement: "b1d9ab7", type: "runtime", source: "flake.lock"),
        Bibliothecary::Dependency.new(platform: "nix", name: "home-manager", requirement: "f339001", type: "runtime", source: "flake.lock"),
        Bibliothecary::Dependency.new(platform: "nix", name: "nixpkgs", requirement: "44d0940", type: "runtime", source: "flake.lock"),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "parses dependencies from nix/sources.json (niv)" do
    expect(described_class.analyse_contents("nix/sources.json", load_fixture("nix/sources.json"))).to eq({
      platform: "nix",
      path: "nix/sources.json",
      project_name: nil,
      dependencies: [
        Bibliothecary::Dependency.new(platform: "nix", name: "nixpkgs", requirement: "44d0940", type: "runtime", source: "nix/sources.json"),
        Bibliothecary::Dependency.new(platform: "nix", name: "home-manager", requirement: "f339001", type: "runtime", source: "nix/sources.json"),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "parses dependencies from npins/sources.json" do
    expect(described_class.analyse_contents("npins/sources.json", load_fixture("npins/sources.json"))).to eq({
      platform: "nix",
      path: "npins/sources.json",
      project_name: nil,
      dependencies: [
        Bibliothecary::Dependency.new(platform: "nix", name: "nixpkgs", requirement: "44d0940", type: "runtime", source: "npins/sources.json"),
        Bibliothecary::Dependency.new(platform: "nix", name: "pre-commit-hooks", requirement: "a439ba3", type: "runtime", source: "npins/sources.json"),
      ],
      kind: "lockfile",
      success: true,
    })
  end

  it "matches valid filepaths" do
    expect(described_class.match?("flake.nix")).to be_truthy
    expect(described_class.match?("flake.lock")).to be_truthy
    expect(described_class.match?("nix/sources.json")).to be_truthy
    expect(described_class.match?("npins/sources.json")).to be_truthy
  end

  it "does not match invalid filepaths" do
    expect(described_class.match?("default.nix")).to be_falsey
    expect(described_class.match?("shell.nix")).to be_falsey
    expect(described_class.match?("sources.json")).to be_falsey
  end

  describe ".parse_flake_url" do
    it "parses github URLs with ref" do
      expect(described_class.parse_flake_url("github:NixOS/nixpkgs/nixos-unstable")).to eq("nixos-unstable")
    end

    it "parses github URLs without ref" do
      expect(described_class.parse_flake_url("github:numtide/flake-utils")).to eq("*")
    end

    it "parses gitlab URLs with ref" do
      expect(described_class.parse_flake_url("gitlab:foo/bar/v1.0")).to eq("v1.0")
    end

    it "parses URLs with ref query param" do
      expect(described_class.parse_flake_url("git+https://github.com/foo/bar?ref=main")).to eq("main")
    end

    it "parses URLs with rev query param" do
      expect(described_class.parse_flake_url("git+https://github.com/foo/bar?rev=abc123")).to eq("abc123")
    end

    it "returns * for unknown formats" do
      expect(described_class.parse_flake_url("path:/some/local/path")).to eq("*")
    end
  end
end
