# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::CPAN do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("cpan")
  end

  it "parses dependencies from META.yml" do
    expect(described_class.analyse_contents("META.yml", load_fixture("META.yml"))).to eq({
                                                                                           platform: "cpan",
                                                                                           path: "META.yml",
                                                                                           project_name: nil,
                                                                                           dependencies: [
        Bibliothecary::Dependency.new(platform: "cpan", name: "Digest::MD5", requirement: 0, type: "runtime", source: "META.yml"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "File::Temp", requirement: 0, type: "runtime", source: "META.yml"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "LWP", requirement: 0, type: "runtime", source: "META.yml"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "XML::Simple", requirement: 0, type: "runtime", source: "META.yml"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "perl", requirement: "5.6.0", type: "runtime", source: "META.yml"),
      ],
                                                                                           kind: "lockfile",
                                                                                           success: true,
                                                                                         })
  end

  it "parses dependencies from META.json" do
    expect(described_class.analyse_contents("META.json", load_fixture("META.json"))).to eq({
                                                                                             platform: "cpan",
                                                                                             path: "META.json",
                                                                                             project_name: nil,
                                                                                             dependencies: [
        Bibliothecary::Dependency.new(platform: "cpan", name: "English", requirement: "1.00", type: "runtime", source: "META.json"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "Test::More", requirement: "0.45", type: "runtime", source: "META.json"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "Module::Build", requirement: "0.28", type: "runtime", source: "META.json"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "Getopt::Long", requirement: "2.32", type: "runtime", source: "META.json"),
        Bibliothecary::Dependency.new(platform: "cpan", name: "List::Util", requirement: "1.07_00", type: "runtime", source: "META.json"),
      ],
                                                                                             kind: "lockfile",
                                                                                             success: true,
                                                                                           })
  end

  it "parses dependencies from cpanfile" do
    result = described_class.analyse_contents("cpanfile", load_fixture("cpanfile"))
    expect(result[:platform]).to eq("cpan")
    expect(result[:path]).to eq("cpanfile")
    expect(result[:kind]).to eq("manifest")
    expect(result[:success]).to be true

    deps = result[:dependencies]
    expect(deps.length).to be > 100

    # Check a specific dependency with version
    list_more_utils = deps.find { |d| d.name == "List::MoreUtils" }
    expect(list_more_utils).not_to be_nil
    expect(list_more_utils.requirement).to eq("0.402")
    expect(list_more_utils.type).to eq("runtime")

    # Check a dependency without version
    local_lib = deps.find { |d| d.name == "local::lib" }
    expect(local_lib).not_to be_nil
    expect(local_lib.requirement).to eq("*")

    # Check feature dependencies are included
    soap_lite = deps.find { |d| d.name == "SOAP::Lite" }
    expect(soap_lite).not_to be_nil
  end

  it "parses dependencies from cpanfile.snapshot" do
    result = described_class.analyse_contents("cpanfile.snapshot", load_fixture("cpanfile.snapshot"))
    expect(result[:platform]).to eq("cpan")
    expect(result[:path]).to eq("cpanfile.snapshot")
    expect(result[:kind]).to eq("lockfile")
    expect(result[:success]).to be true

    deps = result[:dependencies]
    expect(deps.length).to be > 50

    # Check specific locked dependencies
    algorithm_c3 = deps.find { |d| d.name == "Algorithm::C3" }
    expect(algorithm_c3).not_to be_nil
    expect(algorithm_c3.requirement).to eq("0.08")

    cgi = deps.find { |d| d.name == "CGI" }
    expect(cgi).not_to be_nil
    expect(cgi.requirement).to eq("4.28")
  end

  it "parses dependencies from Makefile.PL" do
    result = described_class.analyse_contents("Makefile.PL", load_fixture("Makefile.PL"))
    expect(result[:platform]).to eq("cpan")
    expect(result[:path]).to eq("Makefile.PL")
    expect(result[:kind]).to eq("manifest")
    expect(result[:success]).to be true

    deps = result[:dependencies]

    # Check runtime dependencies (PREREQ_PM)
    moo = deps.find { |d| d.name == "Moo" }
    expect(moo).not_to be_nil
    expect(moo.requirement).to eq("2.0")
    expect(moo.type).to eq("runtime")

    json_xs = deps.find { |d| d.name == "JSON::XS" }
    expect(json_xs).not_to be_nil
    expect(json_xs.requirement).to eq("*")

    # Check test dependencies (TEST_REQUIRES)
    test_more = deps.find { |d| d.name == "Test::More" }
    expect(test_more).not_to be_nil
    expect(test_more.requirement).to eq("0.88")
    expect(test_more.type).to eq("test")

    # Check build dependencies (BUILD_REQUIRES and CONFIGURE_REQUIRES)
    build_deps = deps.select { |d| d.type == "build" }
    expect(build_deps.map(&:name)).to include("File::Temp", "ExtUtils::MakeMaker")
  end

  it "parses dependencies from Build.PL" do
    result = described_class.analyse_contents("Build.PL", load_fixture("Build.PL"))
    expect(result[:platform]).to eq("cpan")
    expect(result[:path]).to eq("Build.PL")
    expect(result[:kind]).to eq("manifest")
    expect(result[:success]).to be true

    deps = result[:dependencies]

    # Check runtime dependencies (requires)
    moose = deps.find { |d| d.name == "Moose" }
    expect(moose).not_to be_nil
    expect(moose.requirement).to eq("2.0")
    expect(moose.type).to eq("runtime")

    try_tiny = deps.find { |d| d.name == "Try::Tiny" }
    expect(try_tiny).not_to be_nil
    expect(try_tiny.requirement).to eq("0.22")

    # Check test dependencies (test_requires)
    test_more = deps.find { |d| d.name == "Test::More" }
    expect(test_more).not_to be_nil
    expect(test_more.requirement).to eq("0.96")
    expect(test_more.type).to eq("test")

    # Check recommends
    json_xs = deps.find { |d| d.name == "JSON::XS" }
    expect(json_xs).not_to be_nil
    expect(json_xs.requirement).to eq("3.0")

    # perl itself should not be included
    perl_dep = deps.find { |d| d.name == "perl" }
    expect(perl_dep).to be_nil
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("META.yml")).to be_truthy
    expect(described_class.match?("META.json")).to be_truthy
    expect(described_class.match?("cpanfile")).to be_truthy
    expect(described_class.match?("cpanfile.snapshot")).to be_truthy
    expect(described_class.match?("Makefile.PL")).to be_truthy
    expect(described_class.match?("Build.PL")).to be_truthy
  end
end
