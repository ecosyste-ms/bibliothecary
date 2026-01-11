# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Rpm do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("rpm")
  end

  it "parses dependencies from .spec file" do
    result = described_class.analyse_contents("hello.spec", load_fixture("hello.spec"))

    expect(result).to eq({
      platform: "rpm",
      path: "hello.spec",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "rpm", name: "gcc", requirement: "*", type: "build", source: "hello.spec"),
        Bibliothecary::Dependency.new(platform: "rpm", name: "make", requirement: "*", type: "build", source: "hello.spec"),
        Bibliothecary::Dependency.new(platform: "rpm", name: "gettext", requirement: ">= 0.19", type: "build", source: "hello.spec"),
        Bibliothecary::Dependency.new(platform: "rpm", name: "autoconf", requirement: "*", type: "build", source: "hello.spec"),
        Bibliothecary::Dependency.new(platform: "rpm", name: "automake", requirement: "*", type: "build", source: "hello.spec"),
        Bibliothecary::Dependency.new(platform: "rpm", name: "glibc", requirement: ">= 2.17", type: "runtime", source: "hello.spec"),
        Bibliothecary::Dependency.new(platform: "rpm", name: "info", requirement: "*", type: "runtime", source: "hello.spec"),
        Bibliothecary::Dependency.new(platform: "rpm", name: "info", requirement: "*", type: "runtime", source: "hello.spec"),
        Bibliothecary::Dependency.new(platform: "rpm", name: "info", requirement: "*", type: "runtime", source: "hello.spec"),
      ],
      kind: "manifest",
      project_name: nil,
      success: true,
    })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("hello.spec")).to be_truthy
    expect(described_class.match?("SPECS/package.spec")).to be_truthy
    expect(described_class.match?("package.rpm")).to be_falsey
    expect(described_class.match?("Makefile")).to be_falsey
  end
end
