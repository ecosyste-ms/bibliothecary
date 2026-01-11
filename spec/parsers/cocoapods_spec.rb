# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::CocoaPods do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("cocoapods")
  end

  it "parses dependencies from Podfile" do
    expect(described_class.analyse_contents("Podfile", load_fixture("Podfile"))).to eq({
                                                                                         platform: "cocoapods",
                                                                                         path: "Podfile",
                                                                                         project_name: nil,
                                                                                         dependencies: [
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Artsy-UIButtons", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ORStackView", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "FLKAutoLayout", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ISO8601DateFormatter", requirement: "= 0.7", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ARCollectionViewMasonryLayout", requirement: "~> 2.0.0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "SDWebImage", requirement: "~> 3.7", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "SVProgressHUD", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "CardFlight", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Stripe", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ECPhoneNumberFormatter", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "UIImageViewAligned", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "DZNWebViewController", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Reachability", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ARTiledImageView", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "XNGMarkdownParser", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "SwiftyJSON", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "ReactiveCocoa", requirement: "~> 4.0.1-alpha-2", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Swift-RAC-Macros", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "FBSnapshotTestCase", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Nimble-Snapshots", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Quick", requirement: ">= 0", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Nimble", requirement: "= 2.0.0-rc.3", type: "runtime", source: "Podfile"),
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "Forgeries", requirement: ">= 0", type: "runtime", source: "Podfile"),
      ],
                                                                                         kind: "manifest",
                                                                                         success: true,
                                                                                       })
  end

  it "parses dependencies from Podfile.lock" do
    result = described_class.analyse_contents("Podfile.lock", load_fixture("Podfile.lock"))
    expect(result).to include({
                                platform: "cocoapods",
                                path: "Podfile.lock",
                                project_name: nil,
                                kind: "lockfile",
                                success: true,
                              })
    expect(result[:dependencies].length).to eq(50)
    # Spot check dependencies with integrity from SPEC CHECKSUMS section
    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(platform: "cocoapods", name: "Alamofire", requirement: "2.0.1", type: "runtime", source: "Podfile.lock", integrity: "sha1=1d8e208d616fbbfd2391b15eae766d07c96cdc49"),
      Bibliothecary::Dependency.new(platform: "cocoapods", name: "Quick", requirement: "0.6.0", type: "runtime", source: "Podfile.lock", integrity: "sha1=563686dbcf0ae0f9f7401ac9cd2d786ee1b7f3d7"),
      Bibliothecary::Dependency.new(platform: "cocoapods", name: "SwiftyJSON", requirement: "2.2.1", type: "runtime", source: "Podfile.lock", integrity: "sha1=ae2d0a3d68025d136602a33c4ee215091ced3e33")
    )
  end

  it "parses dependencies from example.podspec" do
    expect(described_class.analyse_contents("example.podspec", load_fixture("example.podspec"))).to eq({
                                                                                                         platform: "cocoapods",
                                                                                                         path: "example.podspec",
                                                                                                         project_name: nil,
                                                                                                         dependencies: [
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "CocoaLumberjack", requirement: ">= 0", type: "runtime", source: "example.podspec"),
      ],
                                                                                                         kind: "manifest",
                                                                                                         success: true,
                                                                                                       })
  end

  it "parses dependencies from example.podspec.json" do
    expect(described_class.analyse_contents("example.podspec.json", load_fixture("example.podspec.json"))).to eq({
                                                                                                                   platform: "cocoapods",
                                                                                                                   path: "example.podspec.json",
                                                                                                                   project_name: nil,
                                                                                                                   dependencies: [
        Bibliothecary::Dependency.new(platform: "cocoapods", name: "OpenSSL", requirement: ["~> 1.0"], type: "runtime", source: "example.podspec.json"),
      ],
                                                                                                                   kind: "manifest",
                                                                                                                   success: true,
                                                                                                                 })
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("Podfile")).to be_truthy
    expect(described_class.match?("Podfile.lock")).to be_truthy
    expect(described_class.match?("devise.podspec")).to be_truthy
    expect(described_class.match?("foo_meh-bar.podspec")).to be_truthy
    expect(described_class.match?("devise.podspec.json")).to be_truthy
  end
end
