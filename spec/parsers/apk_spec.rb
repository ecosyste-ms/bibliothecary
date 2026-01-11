# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Apk do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("apk")
  end

  it "parses dependencies from APKBUILD" do
    result = described_class.analyse_contents("APKBUILD", load_fixture("APKBUILD"))

    expect(result).to eq({
      platform: "apk",
      path: "APKBUILD",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "apk", name: "ca-certificates-bundle", requirement: "*", type: "runtime", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "perl", requirement: "*", type: "build", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "python3", requirement: "*", type: "build", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "nghttp2", requirement: "*", type: "test", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "python3", requirement: "*", type: "test", source: "APKBUILD"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "parses dependencies with version constraints from APKBUILD" do
    result = described_class.analyse_contents("APKBUILD", load_fixture("APKBUILD-with-versions"))

    expect(result).to eq({
      platform: "apk",
      path: "APKBUILD",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "apk", name: "libfoo", requirement: ">=1.0", type: "runtime", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "libbar", requirement: "<2.0", type: "runtime", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "libbaz", requirement: "*", type: "runtime", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "gcc", requirement: "*", type: "build", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "make", requirement: "*", type: "build", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "openssl-dev", requirement: ">3", type: "build", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "zlib-dev", requirement: ">=1.2.3", type: "build", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "pytest", requirement: "*", type: "test", source: "APKBUILD"),
        Bibliothecary::Dependency.new(platform: "apk", name: "python3", requirement: ">=3.9", type: "test", source: "APKBUILD"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("APKBUILD")).to be_truthy
    expect(described_class.match?("subdir/APKBUILD")).to be_truthy
    expect(described_class.match?("Makefile")).to be_falsey
  end
end
