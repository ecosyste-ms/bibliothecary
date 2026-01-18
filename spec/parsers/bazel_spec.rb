# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::Bazel do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("bazel")
  end

  it "parses dependencies from MODULE.bazel" do
    expect(described_class.analyse_contents("MODULE.bazel", load_fixture("MODULE.bazel"))).to eq({
                                                                                         platform: "bazel",
                                                                                         path: "MODULE.bazel",
                                                                                         project_name: nil,
                                                                                         dependencies: [
        Bibliothecary::Dependency.new(platform: "bazel", name: "j2cl", requirement: "*", type: "runtime", source: "MODULE.bazel"),
        Bibliothecary::Dependency.new(platform: "bazel", name: "jsinterop_generator", requirement: "20250812", type: "runtime", source: "MODULE.bazel"),
        Bibliothecary::Dependency.new(platform: "bazel", name: "jsinterop_base", requirement: "1.1.0", type: "runtime", source: "MODULE.bazel"),
        Bibliothecary::Dependency.new(platform: "bazel", name: "bazel_skylib", requirement: "1.7.1", type: "runtime", source: "MODULE.bazel"),
        Bibliothecary::Dependency.new(platform: "bazel", name: "google_bazel_common", requirement: "0.0.1", type: "runtime", source: "MODULE.bazel"),
        Bibliothecary::Dependency.new(platform: "bazel", name: "rules_java", requirement: "8.13.0", type: "runtime", source: "MODULE.bazel"),
        Bibliothecary::Dependency.new(platform: "bazel", name: "rules_license", requirement: "1.0.0", type: "runtime", source: "MODULE.bazel"),
        Bibliothecary::Dependency.new(platform: "bazel", name: "google_benchmark", requirement: "1.9.4", type: "development", source: "MODULE.bazel"),
        Bibliothecary::Dependency.new(platform: "bazel", name: "rules_jvm_external", requirement: "6.6", type: "runtime", source: "MODULE.bazel"),
      ],
                                                                                         kind: "manifest",
                                                                                         success: true,
                                                                                       })
  end
  it "matches valid manifest filepaths" do
    expect(described_class.match?("MODULE.bazel")).to be_truthy
  end
end
