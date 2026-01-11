# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Deb do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("deb")
  end

  it "parses dependencies from debian/control" do
    result = described_class.analyse_contents("debian/control", load_fixture("debian/control"))

    expect(result).to eq({
      platform: "deb",
      path: "debian/control",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "deb", name: "debhelper-compat", requirement: "= 13", type: "build", source: "debian/control"),
        Bibliothecary::Dependency.new(platform: "deb", name: "gcc", requirement: ">= 4:10", type: "build", source: "debian/control"),
        Bibliothecary::Dependency.new(platform: "deb", name: "gettext", requirement: "*", type: "build", source: "debian/control"),
        Bibliothecary::Dependency.new(platform: "deb", name: "texinfo", requirement: "*", type: "build", source: "debian/control"),
        Bibliothecary::Dependency.new(platform: "deb", name: "libc6", requirement: ">= 2.17", type: "runtime", source: "debian/control"),
        Bibliothecary::Dependency.new(platform: "deb", name: "dpkg", requirement: ">= 1.17.5", type: "runtime", source: "debian/control"),
        Bibliothecary::Dependency.new(platform: "deb", name: "info", requirement: "*", type: "runtime", source: "debian/control"),
        Bibliothecary::Dependency.new(platform: "deb", name: "gettext-doc", requirement: "*", type: "runtime", source: "debian/control"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("debian/control")).to be_truthy
    expect(described_class.match?("some/path/debian/control")).to be_truthy
    expect(described_class.match?("control")).to be_truthy
    expect(described_class.match?("Makefile")).to be_falsey
  end
end
