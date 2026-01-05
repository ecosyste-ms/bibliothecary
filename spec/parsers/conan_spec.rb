require "spec_helper"

describe Bibliothecary::Parsers::Conan do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("conan")
  end

  it "parses dependencies from conanfile.txt" do
    result = described_class.analyse_contents("conanfile.txt", load_fixture("conanfile.txt"))
    expect(result[:platform]).to eq("conan")
    expect(result[:kind]).to eq("manifest")
    expect(result[:dependencies]).to eq([
      Bibliothecary::Dependency.new(name: "zlib", requirement: "1.2.11", type: "runtime", platform: "conan", source: "conanfile.txt"),
      Bibliothecary::Dependency.new(name: "boost", requirement: "1.76.0", type: "runtime", platform: "conan", source: "conanfile.txt"),
      Bibliothecary::Dependency.new(name: "cmake", requirement: "3.21.0", type: "development", platform: "conan", source: "conanfile.txt"),
    ])
  end

  it "parses dependencies from conanfile.py" do
    result = described_class.analyse_contents("conanfile.py", load_fixture("conanfile.py"))
    expect(result[:platform]).to eq("conan")
    expect(result[:kind]).to eq("manifest")
    expect(result[:dependencies]).to eq([
      Bibliothecary::Dependency.new(name: "zlib", requirement: "1.2.11", type: "runtime", platform: "conan", source: "conanfile.py"),
      Bibliothecary::Dependency.new(name: "boost", requirement: "1.76.0", type: "runtime", platform: "conan", source: "conanfile.py"),
    ])
  end

  it "parses dependencies from conan.lock" do
    result = described_class.analyse_contents("conan.lock", load_fixture("conan.lock"))
    expect(result[:platform]).to eq("conan")
    expect(result[:kind]).to eq("lockfile")
    expect(result[:dependencies]).to eq([
      Bibliothecary::Dependency.new(name: "zlib", requirement: "1.2.11", type: "runtime", platform: "conan", source: "conan.lock"),
      Bibliothecary::Dependency.new(name: "boost", requirement: "1.76.0", type: "runtime", platform: "conan", source: "conan.lock"),
      Bibliothecary::Dependency.new(name: "cmake", requirement: "3.21.0", type: "development", platform: "conan", source: "conan.lock"),
    ])
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("conanfile.txt")).to be_truthy
    expect(described_class.match?("conanfile.py")).to be_truthy
    expect(described_class.match?("conan.lock")).to be_truthy
  end
end
