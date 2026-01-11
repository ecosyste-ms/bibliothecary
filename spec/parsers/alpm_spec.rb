# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Alpm do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("alpm")
  end

  it "parses dependencies from PKGBUILD" do
    result = described_class.analyse_contents("PKGBUILD", load_fixture("PKGBUILD"))

    expect(result).to eq({
      platform: "alpm",
      path: "PKGBUILD",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "alpm", name: "glibc", requirement: ">=2.17", type: "runtime", source: "PKGBUILD"),
        Bibliothecary::Dependency.new(platform: "alpm", name: "sh", requirement: "*", type: "runtime", source: "PKGBUILD"),
        Bibliothecary::Dependency.new(platform: "alpm", name: "gcc", requirement: "*", type: "build", source: "PKGBUILD"),
        Bibliothecary::Dependency.new(platform: "alpm", name: "make", requirement: "*", type: "build", source: "PKGBUILD"),
        Bibliothecary::Dependency.new(platform: "alpm", name: "gettext", requirement: ">=0.19", type: "build", source: "PKGBUILD"),
        Bibliothecary::Dependency.new(platform: "alpm", name: "dejagnu", requirement: "*", type: "test", source: "PKGBUILD"),
        Bibliothecary::Dependency.new(platform: "alpm", name: "python", requirement: "*", type: "test", source: "PKGBUILD"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("PKGBUILD")).to be_truthy
    expect(described_class.match?("subdir/PKGBUILD")).to be_truthy
    expect(described_class.match?("APKBUILD")).to be_falsey
  end
end
