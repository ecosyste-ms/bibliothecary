# frozen_string_literal: true

require "spec_helper"

describe Bibliothecary::Parsers::NPM do
  it "has a platform name" do
    expect(described_class.platform_name).to eq("npm")
  end

  it "parses dependencies from npm-ls.json" do
    expect(described_class.analyse_contents("npm-ls.json", load_fixture("npm-ls.json"))).to eq({
                                                                                                 platform: "npm",
                                                                                                 path: "npm-ls.json",
                                                                                                 project_name: nil,
                                                                                                 dependencies: [
        Bibliothecary::Dependency.new(platform: "npm", name: "ansicolor", requirement: "1.1.93", type: "runtime", source: "npm-ls.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "babel-cli", requirement: "6.26.0", type: "runtime", source: "npm-ls.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.6.9", type: "runtime", source: "npm-ls.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "babel-polyfill", requirement: "6.26.0", type: "runtime", source: "npm-ls.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "core-js", requirement: "2.6.12", type: "runtime", source: "npm-ls.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "lodash", requirement: "4.17.21", type: "runtime", source: "npm-ls.json"),
      ],
                                                                                                 kind: "lockfile",
                                                                                                 success: true,
                                                                                               })
  end

  it "parses dependencies from package.json" do
    expect(described_class.analyse_contents("package.json", load_fixture("package.json"))).to eq({
                                                                                                   platform: "npm",
                                                                                                   path: "package.json",
                                                                                                   project_name: nil,
                                                                                                   dependencies: [
        Bibliothecary::Dependency.new(platform: "npm", name: "babel", requirement: "^4.6.6", type: "runtime", local: false, source: "package.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "@some-scope/actual-package", requirement: "^1.1.3", original_name: "alias-package-name", original_requirement: "^1.1.3", type: "runtime", local: false, source: "package.json"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mocha", requirement: "^2.2.1", type: "development", local: false, source: "package.json"),
      ],
                                                                                                   kind: "manifest",
                                                                                                   success: true,
                                                                                                 })
  end

  it "parses dependencies from npm-shrinkwrap.json" do
    expect(described_class.analyse_contents("npm-shrinkwrap.json", load_fixture("npm-shrinkwrap.json"))).to include({
                                                                                                                      platform: "npm",
                                                                                                                      path: "npm-shrinkwrap.json",
                                                                                                                      kind: "lockfile",
                                                                                                                      project_name: nil,
                                                                                                                      success: true,
                                                                                                                    })
    expect(described_class.analyse_contents("npm-shrinkwrap.json", load_fixture("npm-shrinkwrap.json"))[:dependencies]).to include(
      Bibliothecary::Dependency.new(platform: "npm", name: "babel", requirement: "4.7.16", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "body-parser", requirement: "1.13.3", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "bugsnag", requirement: "1.6.5", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "cookie-session", requirement: "1.2.0", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.2.0", type: "development", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "deep-diff", requirement: "0.3.2", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "deep-equal", requirement: "1.0.0", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "express", requirement: "4.13.3", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "express-session", requirement: "1.11.3", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "jade", requirement: "1.11.0", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "js-yaml", requirement: "3.4.0", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "memwatch-next", requirement: "0.2.9", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "multer", requirement: "0.1.8", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "qs", requirement: "2.4.2", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "redis", requirement: "0.12.1", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "semver", requirement: "4.3.6", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "serve-static", requirement: "1.10.0", type: "runtime", source: "npm-shrinkwrap.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "toml", requirement: "2.3.0", type: "runtime", source: "npm-shrinkwrap.json")
    )
  end

  context "with a yarn.lock" do
    let(:expected_deps) do
      [
        Bibliothecary::Dependency.new(platform: "npm", name: "body-parser", requirement: "1.16.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "bytes", requirement: "2.4.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "content-type", requirement: "1.0.2", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "debug", requirement: "2.6.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "depd", requirement: "1.1.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ee-first", requirement: "1.1.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "http-errors", requirement: "1.5.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "iconv-lite", requirement: "0.4.15", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "inherits", requirement: "2.0.3", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "media-typer", requirement: "0.3.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mime-db", requirement: "1.26.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "mime-types", requirement: "2.1.14", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "ms", requirement: "0.7.2", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "on-finished", requirement: "2.3.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "qs", requirement: "6.2.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "raw-body", requirement: "2.2.0", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "setprototypeof", requirement: "1.0.2", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "statuses", requirement: "1.3.1", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "@some-scope/actual-package", requirement: "1.1.3", original_name: "alias-package-name", original_requirement: "1.1.3", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "type-is", requirement: "1.6.14", type: nil, local: false, source: "yarn.lock"),
        Bibliothecary::Dependency.new(platform: "npm", name: "unpipe", requirement: "1.0.0", type: nil, local: false, source: "yarn.lock"),
      ]
    end

    it "parses dependencies" do
      result = described_class.analyse_contents("yarn.lock", load_fixture("yarn.lock"))
      expect(result).to eq({
                             platform: "npm",
                             path: "yarn.lock",
                             dependencies: expected_deps,
                             kind: "lockfile",
                             project_name: nil,
                             success: true,
                           })
    end

    it "parses dependencies with windows line endings" do
      result = described_class.analyse_contents(
        "yarn.lock",
        load_fixture("yarn.lock").gsub("\n", "\r\n")
      )
      expect(result).to eq({
                             platform: "npm",
                             path: "yarn.lock",
                             dependencies: expected_deps,
                             kind: "lockfile",
                             project_name: nil,
                             success: true,
                           })
    end
  end

  it "parses git dependencies from yarn.lock" do
    expect(described_class.analyse_contents("yarn.lock", load_fixture("yarn-with-git-repo/yarn.lock"))).to eq({
                                                                                                                platform: "npm",
                                                                                                                path: "yarn.lock",
                                                                                                                project_name: nil,
                                                                                                                dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "vue", requirement: "2.6.12", type: nil, local: false, source: "yarn.lock"),
        ],
                                                                                                                kind: "lockfile",
                                                                                                                success: true,
                                                                                                              })
  end

  it "parses dependencies from pnpm-lock.yaml with lockfile version 5" do
    result = described_class.analyse_contents("pnpm-lock.yaml", load_fixture("pnpm-lockfile-version-5/pnpm-lock.yaml"))

    expect(result).to include({
                                platform: "npm",
                                path: "pnpm-lock.yaml",
                                kind: "lockfile",
                                project_name: nil,
                                success: true,
                              })
    expect(result[:dependencies].length).to eq(108)
    # Spot check key dependencies with integrity
    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/types", requirement: "7.28.1", type: "runtime", source: "pnpm-lock.yaml", integrity: "sha512-x0LvFTekgSX+83TI28Y9wYPUfzrnl2aT5+5QLnO6v7mSJYtEEevuDRN0F0uSHRk1G1IWZC43o00Y0xDDrpBGPQ=="),
      Bibliothecary::Dependency.new(platform: "npm", name: "zod", requirement: "4.0.5", original_name: "alias-package", original_requirement: "4.0.5", type: "runtime", source: "pnpm-lock.yaml", integrity: "sha512-/5UuuRPStvHXu7RS+gmvRf4NXrNxpSllGwDnCBcJZtQsKrviYXm54yDGV2KYNLT5kq0lHGcl7lqWJLgSaG+tgA=="),
      Bibliothecary::Dependency.new(platform: "npm", name: "mocha", requirement: "2.5.3", type: "development", source: "pnpm-lock.yaml", integrity: "sha512-jNt2iEk9FPmZLzL+sm4FNyOIDYXf2wUU6L4Cc8OIKK/kzgMHKPi4YhTZqG4bW4kQVdIv6wutDybRhXfdnujA1Q==")
    )
  end

  it "parses dependencies from pnpm-lock.yaml with lockfile version 6" do
    result = described_class.analyse_contents("pnpm-lock.yaml", load_fixture("pnpm-lockfile-version-6/pnpm-lock.yaml"))

    expect(result).to include({
                                platform: "npm",
                                path: "pnpm-lock.yaml",
                                kind: "lockfile",
                                project_name: nil,
                                success: true,
                              })
    expect(result[:dependencies].length).to eq(108)
    # Spot check key dependencies with integrity
    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/types", requirement: "7.28.1", type: "runtime", source: "pnpm-lock.yaml", integrity: "sha512-x0LvFTekgSX+83TI28Y9wYPUfzrnl2aT5+5QLnO6v7mSJYtEEevuDRN0F0uSHRk1G1IWZC43o00Y0xDDrpBGPQ=="),
      Bibliothecary::Dependency.new(platform: "npm", name: "zod", requirement: "4.0.5", original_name: "alias-package", original_requirement: "4.0.5", type: "runtime", source: "pnpm-lock.yaml", integrity: "sha512-/5UuuRPStvHXu7RS+gmvRf4NXrNxpSllGwDnCBcJZtQsKrviYXm54yDGV2KYNLT5kq0lHGcl7lqWJLgSaG+tgA=="),
      Bibliothecary::Dependency.new(platform: "npm", name: "mocha", requirement: "2.5.3", type: "development", source: "pnpm-lock.yaml", integrity: "sha512-jNt2iEk9FPmZLzL+sm4FNyOIDYXf2wUU6L4Cc8OIKK/kzgMHKPi4YhTZqG4bW4kQVdIv6wutDybRhXfdnujA1Q==")
    )
  end

  it "parses dependencies from pnpm-lock.yaml with lockfile version 9" do
    result = described_class.analyse_contents("pnpm-lock.yaml", load_fixture("pnpm-lockfile-version-9/pnpm-lock.yaml"))

    expect(result).to include({
                                platform: "npm",
                                path: "pnpm-lock.yaml",
                                kind: "lockfile",
                                project_name: nil,
                                success: true,
                              })
    expect(result[:dependencies].length).to eq(108)
    # Spot check key dependencies with integrity
    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(platform: "npm", name: "@babel/types", requirement: "7.28.1", type: "runtime", source: "pnpm-lock.yaml", integrity: "sha512-x0LvFTekgSX+83TI28Y9wYPUfzrnl2aT5+5QLnO6v7mSJYtEEevuDRN0F0uSHRk1G1IWZC43o00Y0xDDrpBGPQ=="),
      Bibliothecary::Dependency.new(platform: "npm", name: "zod", requirement: "3.24.2", original_name: "alias-package", original_requirement: "3.24.2", type: "runtime", source: "pnpm-lock.yaml", integrity: "sha512-lY7CDW43ECgW9u1TcT3IoXHflywfVqDYze4waEz812jR/bZ8FHDsl7pFQoSZTz5N+2NqRXs8GBwnAwo3ZNxqhQ=="),
      Bibliothecary::Dependency.new(platform: "npm", name: "mocha", requirement: "2.5.3", type: "development", source: "pnpm-lock.yaml", integrity: "sha512-jNt2iEk9FPmZLzL+sm4FNyOIDYXf2wUU6L4Cc8OIKK/kzgMHKPi4YhTZqG4bW4kQVdIv6wutDybRhXfdnujA1Q==")
    )
  end

  it "parses dependencies from pnpm-workspace.yaml with catalog" do
    result = described_class.analyse_contents("pnpm-workspace.yaml", load_fixture("pnpm-workspace.yaml"))

    expect(result).to eq({
                           platform: "npm",
                           path: "pnpm-workspace.yaml",
                           dependencies: [
                             Bibliothecary::Dependency.new(platform: "npm", name: "react", requirement: "^18.3.1", type: "runtime", source: "pnpm-workspace.yaml"),
                             Bibliothecary::Dependency.new(platform: "npm", name: "react-dom", requirement: "^18.3.1", type: "runtime", source: "pnpm-workspace.yaml"),
                             Bibliothecary::Dependency.new(platform: "npm", name: "typescript", requirement: "^5.0.0", type: "runtime", source: "pnpm-workspace.yaml"),
                             Bibliothecary::Dependency.new(platform: "npm", name: "react", requirement: "^17.0.2", type: "runtime", source: "pnpm-workspace.yaml"),
                             Bibliothecary::Dependency.new(platform: "npm", name: "react-dom", requirement: "^17.0.2", type: "runtime", source: "pnpm-workspace.yaml"),
                           ],
                           kind: "manifest",
                           project_name: nil,
                           success: true,
                         })
  end

  it "returns empty dependencies for pnpm-workspace.yaml without catalog" do
    result = described_class.analyse_contents("pnpm-workspace.yaml", load_fixture("pnpm-workspace-no-catalog.yaml"))

    expect(result).to eq({
                           platform: "npm",
                           path: "pnpm-workspace.yaml",
                           dependencies: [],
                           kind: "manifest",
                           project_name: nil,
                           success: true,
                         })
  end

  it "parses git dependencies from package.json" do
    expect(described_class.analyse_contents("package.json", load_fixture("yarn-with-git-repo/package.json"))).to eq({
                                                                                                                      platform: "npm",
                                                                                                                      path: "package.json",
                                                                                                                      project_name: nil,
                                                                                                                      dependencies: [
        Bibliothecary::Dependency.new(platform: "npm", name: "vue", requirement: "https://github.com/vuejs/vue.git#v2.6.12", type: "runtime", local: false, source: "package.json"),
      ],
                                                                                                                      kind: "manifest",
                                                                                                                      success: true,
                                                                                                                    })
  end

  it "wont load package-lock.json from a package.json" do
    expect(described_class.analyse_contents("package.json", load_fixture("package-lock.json"))).to match({
                                                                                                           platform: "npm",
                                                                                                           path: "package.json",
                                                                                                           dependencies: nil,
                                                                                                           kind: "manifest",
                                                                                                           success: false,
                                                                                                           error_message: "package.json: appears to be a lockfile rather than manifest format",
                                                                                                           error_location: match(/in '.*parse_manifest'/),
                                                                                                         })
  end

  it "parses dependencies from package-lock.json" do
    result = described_class.analyse_contents("package-lock.json", load_fixture("package-lock.json"))

    expect(result).to include({
                                platform: "npm",
                                path: "package-lock.json",
                                project_name: nil,
                                kind: "lockfile",
                                success: true,
                              })
    expect(result[:dependencies].length).to eq(202)
    # Spot check key dependencies with integrity
    expect(result[:dependencies]).to include(
      Bibliothecary::Dependency.new(platform: "npm", name: "accepts", requirement: "1.3.3", type: "runtime", source: "package-lock.json", integrity: "sha1-w8p0NJOGSMPg2cHjKN1otiLChMo="),
      Bibliothecary::Dependency.new(platform: "npm", name: "express", requirement: "4.15.3", type: "runtime", source: "package-lock.json", integrity: "sha1-urZdDwOqgMNYQIly/HAPkWlEtmI="),
      Bibliothecary::Dependency.new(platform: "npm", name: "yarn", requirement: "0.24.6", type: "runtime", source: "package-lock.json", integrity: "sha1-ShKESAAEJfRd9c1igLADpiAQRPw=")
    )
  end

  context "with local path dependencies" do
    it "parses local path dependencies from package.json" do
      expect(described_class.analyse_contents("package.json", load_fixture("npm-local-file/package.json"))).to eq({
                                                                                                                    platform: "npm",
                                                                                                                    path: "package.json",
                                                                                                                    project_name: nil,
                                                                                                                    dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "left-pad", requirement: "^1.3.0", type: "runtime", local: false, source: "package.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "other-package", requirement: "file:src/other-package", type: "runtime", local: true, source: "package.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "react", requirement: "^18.3.1", type: "runtime", local: false, source: "package.json"),
        ],
                                                                                                                    kind: "manifest",
                                                                                                                    success: true,
                                                                                                                  })
    end

    it "parses local path dependencies from package-lock.json" do
      expect(described_class.analyse_contents("package-lock.json", load_fixture("npm-local-file/package-lock.json"))).to eq({
                                                                                                                              platform: "npm",
                                                                                                                              path: "package-lock.json",
                                                                                                                              dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "js-tokens", requirement: "4.0.0", type: "runtime", local: false, source: "package-lock.json", integrity: "sha512-RdJUflcE3cUzKiMqQgsCu06FPu9UdIJO0beYbPhHN4k6apgJtifcoCtT9bcxOpYBtpD2kCM6Sbzg4CausW/PKQ=="),
          Bibliothecary::Dependency.new(platform: "npm", name: "left-pad", requirement: "1.3.0", type: "runtime", local: false, source: "package-lock.json", integrity: "sha512-XI5MPzVNApjAyhQzphX8BkmKsKUxD4LdyK24iZeQGinBN9yTQT3bFlCBy/aVx2HrNcqQGsdot8ghrjyrvMCoEA=="),
          Bibliothecary::Dependency.new(platform: "npm", name: "lodash", requirement: "4.17.21", type: "development", local: false, source: "package-lock.json", integrity: "sha512-v2kDEe57lecTulaDIuNTPy3Ry4gLGJ6Z1O3vE1krgXZNrsQ+LFTGHVxVjcXPs17LhbZVGedAJv8XZ1tvj5FvSg=="),
          Bibliothecary::Dependency.new(platform: "npm", name: "loose-envify", requirement: "1.4.0", type: "runtime", local: false, source: "package-lock.json", integrity: "sha512-lyuxPGr/Wfhrlem2CL/UcnUc1zcqKAImBDzukY7Y5F/yQiNdko6+fRLevlw1HgMySw7f611UIY408EtxRSoK3Q=="),
          Bibliothecary::Dependency.new(platform: "npm", name: "other-package", requirement: "*", type: "runtime", local: true, source: "package-lock.json"),
          Bibliothecary::Dependency.new(platform: "npm", name: "react", requirement: "18.3.1", type: "runtime", local: false, source: "package-lock.json", integrity: "sha512-wS+hAgJShR0KhEvPJArfuPVN1+Hz1t0Y6n5jLrGQbkb4urgPE/0Rve+1kMB1v/oWgHgm4WIcV+i7F2pTVj+2iQ=="),
        ],
                                                                                                                              kind: "lockfile",
                                                                                                                              project_name: nil,
                                                                                                                              success: true,
                                                                                                                            })
    end

    it "parses local path dependencies from yarn.lock" do
      expect(described_class.analyse_contents("yarn.lock", load_fixture("npm-local-file/yarn.lock"))).to eq({
                                                                                                              platform: "npm",
                                                                                                              path: "yarn.lock",
                                                                                                              project_name: nil,
                                                                                                              dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "js-tokens", requirement: "4.0.0", type: nil, local: false, source: "yarn.lock"),
          Bibliothecary::Dependency.new(platform: "npm", name: "left-pad", requirement: "1.3.0", type: nil, local: false, source: "yarn.lock"),
          Bibliothecary::Dependency.new(platform: "npm", name: "loose-envify", requirement: "1.4.0", type: nil, local: false, source: "yarn.lock"),
          Bibliothecary::Dependency.new(platform: "npm", name: "other-package", requirement: "1.0.0", type: nil, local: true, source: "yarn.lock"),
          Bibliothecary::Dependency.new(platform: "npm", name: "react", requirement: "18.3.1", type: nil, local: false, source: "yarn.lock"),
        ],
                                                                                                              kind: "lockfile",
                                                                                                              success: true,
                                                                                                            })
    end
  end

  it "does not parse self-referential dependencies from yarn.lock" do
    expect(described_class.analyse_contents("yarn.lock", load_fixture("yarn-v4-lockfile/yarn.lock"))).to eq({
                                                                                                              platform: "npm",
                                                                                                              path: "yarn.lock",
                                                                                                              project_name: nil,
                                                                                                              dependencies: [
  Bibliothecary::Dependency.new(platform: "npm", name: "js-tokens", requirement: "4.0.0", type: nil, local: false, source: "yarn.lock", integrity: "10c0/e248708d377aa058eacf2037b07ded847790e6de892bbad3dac0abba2e759cb9f121b00099a65195616badcb6eca8d14d975cb3e89eb1cfda644756402c8aeed"),
  Bibliothecary::Dependency.new(platform: "npm", name: "left-pad", requirement: "1.3.0", type: nil, local: false, source: "yarn.lock", integrity: "10c0/3fb59c76e281a2f5c810ad71dbbb8eba8b10c6cf94733dc7f27b8c516a5376cacea53543e76f6ae477d866c8954b27f1e15ca349424c2542474eb5bb1d2b6955"),
  Bibliothecary::Dependency.new(platform: "npm", name: "loose-envify", requirement: "1.4.0", type: nil, local: false, source: "yarn.lock", integrity: "10c0/655d110220983c1a4b9c0c679a2e8016d4b67f6e9c7b5435ff5979ecdb20d0813f4dec0a08674fcbdd4846a3f07edbb50a36811fd37930b94aaa0d9daceb017e"),
  Bibliothecary::Dependency.new(platform: "npm", name: "react", requirement: "18.3.1", type: nil, local: false, source: "yarn.lock", integrity: "10c0/283e8c5efcf37802c9d1ce767f302dd569dd97a70d9bb8c7be79a789b9902451e0d16334b05d73299b20f048cbc3c7d288bbbde10b701fa194e2089c237dbea3"),
  Bibliothecary::Dependency.new(platform: "npm", name: "strip-ansi", requirement: "6.0.1", original_name: "strip-ansi-cjs", original_requirement: "6.0.1", type: nil, local: false, source: "yarn.lock", integrity: "10/ae3b5436d34fadeb6096367626ce987057713c566e1e7768818797e00ac5d62023d0f198c4e681eae9e20701721980b26a64a8f5b91238869592a9c6800719a2"),
      ],
                                                                                                              kind: "lockfile",
                                                                                                              success: true,
                                                                                                            })
  end

  it "parses package-lock.json with scm based versions" do
    contents = JSON.dump(
      {
        name: "js-app",
        version: "1.0.0",
        lockfileVersion: 1,
        requires: true,
        dependencies: {
          tagged: {
            version: "git+ssh://git@github.com/some-co/tagged.git#7404d32056c7f0250aa27e038136011b",
            from: "git+ssh://git@github.com/some-co/tagged.git#v2.10.0",
          },
          semver: {
            version: "git+ssh://git@github.com/some-co/semver.git#b8979ec5e34d5fac0f0b3b660dc67f2e",
            from: "git+ssh://git@github.com/some-co/semver.git#semver:v5.5.5",
          },
          head: {
            version: "git+ssh://git@github.com/some-co/head.git#ecce958093a5451452ee1dd0c0d723c9",
            from: "git+ssh://git@github.com/some-co/semver.git",
          },
        },
      }
    )

    expect(described_class.analyse_contents("package-lock.json", contents)[:dependencies]).to eq([
      Bibliothecary::Dependency.new(platform: "npm", name: "tagged", requirement: "2.10.0", type: "runtime", source: "package-lock.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "semver", requirement: "5.5.5", type: "runtime", source: "package-lock.json"),
      Bibliothecary::Dependency.new(platform: "npm", name: "head", requirement: "ecce958093a5451452ee1dd0c0d723c9", type: "runtime", source: "package-lock.json"),
    ])
  end

  it "parses newer package-lock.json with dev and integrity fields" do
    analysis = described_class.analyse_contents("2018-package-lock/package-lock.json", load_fixture("2018-package-lock/package-lock.json"))
    expect(analysis.except(:dependencies)).to eq({
                                                   platform: "npm",
                                                   path: "2018-package-lock/package-lock.json",
                                                   project_name: nil,
                                                   kind: "lockfile",
                                                   success: true,
                                                 })

    # spot-check dependencies to avoid having them all inline here.
    # Mostly for this "2018" lock file we want to be sure dev=true becomes
    # type=development
    dependencies = analysis[:dependencies]
    expect(dependencies[0]).to eq(Bibliothecary::Dependency.new(platform: "npm",
                                                                name: "@vue/test-utils",
                                                                requirement: "1.0.0-beta.13",
                                                                type: "runtime",
                                                                source: "2018-package-lock/package-lock.json",
                                                                integrity: "sha512-HVhh4n8i661BJpVKp2SFUWT9J4kSFFSXF/ZvtlEI2ndEKjNx+1BUGB5V3t3ls1OIDQEFOVoJEuwz3xP/PsCnPQ=="))
    expect(dependencies.select { |dep| dep.type == "runtime" }.length).to eq(373)
    expect(dependencies.select { |dep| dep.type == "development" }.length).to eq(1601)
    # a nested dependency
    expect(dependencies).to include(Bibliothecary::Dependency.new(platform: "npm", name: "acorn", requirement: "4.0.13", type: "development", source: "2018-package-lock/package-lock.json", integrity: "sha1-EFSVrlNh1pe9GVyCUZLhrX8lN4c="))
  end

  it "matches valid manifest filepaths" do
    expect(described_class.match?("package.json")).to be_truthy
    expect(described_class.match?("npm-shrinkwrap.json")).to be_truthy
    expect(described_class.match?("yarn.lock")).to be_truthy
    expect(described_class.match?("website/package.json")).to be_truthy
    expect(described_class.match?("website/yarn.lock")).to be_truthy
    expect(described_class.match?("website/npm-shrinkwrap.json")).to be_truthy
    expect(described_class.match?("package-lock.json")).to be_truthy
    expect(described_class.match?("website/package-lock.json")).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?("foo/apackage.json")).to be_falsey
    expect(described_class.match?("anpm-shrinkwrap.json")).to be_falsey
    expect(described_class.match?("test/pass/yarn.locks")).to be_falsey
    expect(described_class.match?("sa/apackage-lock..json")).to be_falsey
  end

  it "parses dependencies that have multiple versions in package-lock.json" do
    expect(described_class.analyse_contents("package-lock.json", load_fixture("multiple_versions/package-lock.json"))).to eq({
                                                                                                                               dependencies: [
                                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "find-versions", requirement: "4.0.0", type: "runtime", local: false, source: "package-lock.json", integrity: "sha512-wgpWy002tA+wgmO27buH/9KzyEOQnKsG/R0yrcjPT9BOFm0zRBVQbZ95nRGXWMywS8YR5knRbpohio0bcJABxQ=="),
                                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "3.1.3", type: "runtime", local: false, source: "package-lock.json", integrity: "sha512-Aqi54Mk9uYTjVexLnR67rTyBusmwd04cLkHy9hNvk3+G3nT2Oyg7E0l4XVbOaNwIvQ3hHeYxGcyEy+mKreyBFQ=="),
                                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "4.0.2", type: "runtime", local: false, source: "package-lock.json", integrity: "sha512-xyuBZk1XYqQkB687hMQqrCP+J9bdJSjPpZwdmmNjyxKW1K3LDXxqxw91Egaqkh/yheBIVtKPt4/1eybKVdCx3g=="),
                                                                                                                               ],
                                                                                                                               kind: "lockfile",
                                                                                                                               project_name: nil,
                                                                                                                               path: "package-lock.json",
                                                                                                                               platform: "npm",
                                                                                                                               success: true,
                                                                                                                             })
  end

  it "parses dependencies that have multiple versions in yarn.json" do
    expect(described_class.analyse_contents("yarn.lock", load_fixture("multiple_versions/yarn.lock"))).to eq({
                                                                                                               dependencies: [
                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "find-versions", requirement: "4.0.0", type: nil, local: false, source: "yarn.lock"),
                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "3.1.3", type: nil, local: false, source: "yarn.lock"),
                                                                                                                 Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "4.0.2", type: nil, local: false, source: "yarn.lock"),
                                                                                                               ],
                                                                                                               kind: "lockfile",
                                                                                                               path: "yarn.lock",
                                                                                                               project_name: nil,
                                                                                                               platform: "npm",
                                                                                                               success: true,
                                                                                                             })
  end

  describe ".lockfile_preference_order" do
    let!(:shrinkwrap) { Bibliothecary::FileInfo.new(".", "npm-shrinkwrap.json") }
    let!(:package_lock) { Bibliothecary::FileInfo.new(".", "package-lock.json") }
    let!(:package) { Bibliothecary::FileInfo.new(".", "package.json") }

    it "prefers npm-shrinkwrap file infos first" do
      expect(described_class.lockfile_preference_order([
        package, package_lock, shrinkwrap
      ])).to eq([shrinkwrap, package, package_lock])
    end

    it "changes nothing if no shrinkwrap" do
      expect(described_class.lockfile_preference_order([
        package, package_lock
      ])).to eq([package, package_lock])
    end
  end

  context "with different NPM lockfile versions" do
    it "parses version 1 package-lock.json" do
      analysis = described_class.analyse_contents("npm-lockfile-version-1/package-lock.json", load_fixture("npm-lockfile-version-1/package-lock.json"))
      expect(analysis).to eq({
                               platform: "npm",
                               path: "npm-lockfile-version-1/package-lock.json",
                               project_name: nil,
                               dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "find-versions", requirement: "4.0.0", type: "runtime", source: "npm-lockfile-version-1/package-lock.json", integrity: "sha512-wgpWy002tA+wgmO27buH/9KzyEOQnKsG/R0yrcjPT9BOFm0zRBVQbZ95nRGXWMywS8YR5knRbpohio0bcJABxQ=="),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "3.1.4", type: "runtime", source: "npm-lockfile-version-1/package-lock.json", integrity: "sha512-6IiqeZNgq01qGf0TId0t3NvKzSvUsjcpdEO3AQNeIjR6A2+ckTnQlDpl4qu1bjRv0RzN3FP9hzFmws3lKqRWkA=="),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "4.0.5", type: "runtime", source: "npm-lockfile-version-1/package-lock.json", integrity: "sha512-hunMQrEy1T6Jr2uEVjrAIqjwWcQTgOAcIM52C8MY1EZSD3DDNft04XzvYKPqjED65bNVVko0YI38nYeEHCX3yw=="),
        ],
                               kind: "lockfile",
                               success: true,
                             })
    end

    it "parses version 2 package-lock.json" do
      analysis = described_class.analyse_contents("npm-lockfile-version-2/package-lock.json", load_fixture("npm-lockfile-version-2/package-lock.json"))
      expect(analysis).to eq({
                               platform: "npm",
                               path: "npm-lockfile-version-2/package-lock.json",
                               dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "find-versions", requirement: "4.0.0", type: "runtime", local: false, source: "npm-lockfile-version-2/package-lock.json", integrity: "sha512-wgpWy002tA+wgmO27buH/9KzyEOQnKsG/R0yrcjPT9BOFm0zRBVQbZ95nRGXWMywS8YR5knRbpohio0bcJABxQ=="),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "3.1.4", type: "runtime", local: false, source: "npm-lockfile-version-2/package-lock.json", integrity: "sha512-6IiqeZNgq01qGf0TId0t3NvKzSvUsjcpdEO3AQNeIjR6A2+ckTnQlDpl4qu1bjRv0RzN3FP9hzFmws3lKqRWkA=="),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "4.0.5", type: "runtime", local: false, source: "npm-lockfile-version-2/package-lock.json", integrity: "sha512-hunMQrEy1T6Jr2uEVjrAIqjwWcQTgOAcIM52C8MY1EZSD3DDNft04XzvYKPqjED65bNVVko0YI38nYeEHCX3yw=="),
],
                               kind: "lockfile",
                               project_name: nil,
                               success: true,
                             })
    end

    it "parses version 3 package-lock.json" do
      analysis = described_class.analyse_contents("npm-lockfile-version-3/package-lock.json", load_fixture("npm-lockfile-version-3/package-lock.json"))
      expect(analysis).to eq({
                               platform: "npm",
                               path: "npm-lockfile-version-3/package-lock.json",
                               project_name: nil,
                               dependencies: [
          Bibliothecary::Dependency.new(platform: "npm", name: "@some-scope/actual-package", requirement: "1.1.3", original_name: "alias-package-name", original_requirement: "1.1.3", type: "runtime", local: false, source: "npm-lockfile-version-3/package-lock.json", integrity: "sha512-Mo7Byt8jDBtk09ix3hwEYv3hASTAYYTjvyqGnZP+WpxdZHKXb+HTCiNg4tLKDXAharS36RBq8tBQ/AdPbdQn3g=="),
          Bibliothecary::Dependency.new(platform: "npm", name: "find-versions", requirement: "4.0.0", type: "runtime", local: false, source: "npm-lockfile-version-3/package-lock.json", integrity: "sha512-wgpWy002tA+wgmO27buH/9KzyEOQnKsG/R0yrcjPT9BOFm0zRBVQbZ95nRGXWMywS8YR5knRbpohio0bcJABxQ=="),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "3.1.4", type: "runtime", local: false, source: "npm-lockfile-version-3/package-lock.json", integrity: "sha512-6IiqeZNgq01qGf0TId0t3NvKzSvUsjcpdEO3AQNeIjR6A2+ckTnQlDpl4qu1bjRv0RzN3FP9hzFmws3lKqRWkA=="),
          Bibliothecary::Dependency.new(platform: "npm", name: "semver-regex", requirement: "4.0.5", type: "runtime", local: false, source: "npm-lockfile-version-3/package-lock.json", integrity: "sha512-hunMQrEy1T6Jr2uEVjrAIqjwWcQTgOAcIM52C8MY1EZSD3DDNft04XzvYKPqjED65bNVVko0YI38nYeEHCX3yw=="),
],
                               kind: "lockfile",
                               success: true,
                             })
    end
  end

  it "parses bun.lock dependency file" do
    expect(described_class.analyse_contents("bun.lock", load_fixture("bun.lock"))).to eq({
                                                                                           platform: "npm",
                                                                                           path: "bun.lock",
                                                                                           project_name: nil,
                                                                                           dependencies: [

       Bibliothecary::Dependency.new(platform: "npm", name: "@types/bun", requirement: "1.2.5", type: "development", local: false, source: "bun.lock", integrity: "sha512-w2OZTzrZTVtbnJew1pdFmgV99H0/L+Pvw+z1P67HaR18MHOzYnTYOi6qzErhK8HyT+DB782ADVPPE92Xu2/Opg=="),
       Bibliothecary::Dependency.new(platform: "npm", name: "@types/node", requirement: "22.13.10", type: "runtime", local: false, source: "bun.lock", integrity: "sha512-I6LPUvlRH+O6VRUqYOcMudhaIdUVWfsjnZavnsraHvpBwaEyMN29ry+0UVJhImYL16xsscu0aske3yA+uPOWfw=="),
       Bibliothecary::Dependency.new(platform: "npm", name: "@types/ws", requirement: "8.5.14", type: "runtime", local: false, source: "bun.lock", integrity: "sha512-bd/YFLW+URhBzMXurx7lWByOu+xzU9+kb3RboOteXYDfW+tr+JZa99OyNmPINEGB/ahzKrEuc8rcv4gnpJmxTw=="),
       Bibliothecary::Dependency.new(platform: "npm", name: "zod", requirement: "3.24.2", original_name: "alias-package", original_requirement: "3.24.2", type: "runtime", local: false, source: "bun.lock", integrity: "sha512-lY7CDW43ECgW9u1TcT3IoXHflywfVqDYze4waEz812jR/bZ8FHDsl7pFQoSZTz5N+2NqRXs8GBwnAwo3ZNxqhQ=="),
       Bibliothecary::Dependency.new(platform: "npm", name: "babel", requirement: "6.23.0", type: "runtime", local: false, source: "bun.lock", integrity: "sha512-ZDcCaI8Vlct8PJ3DvmyqUz+5X2Ylz3ZuuItBe/74yXosk2dwyVo/aN7MCJ8HJzhnnJ+6yP4o+lDgG9MBe91DLA=="),
       Bibliothecary::Dependency.new(platform: "npm", name: "bun-types", requirement: "1.2.5", type: "runtime", local: false, source: "bun.lock", integrity: "sha512-3oO6LVGGRRKI4kHINx5PIdIgnLRb7l/SprhzqXapmoYkFl5m4j6EvALvbDVuuBFaamB46Ap6HCUxIXNLCGy+tg=="),
       Bibliothecary::Dependency.new(platform: "npm", name: "isarray", requirement: "file:../isarray", type: "runtime", local: true, source: "bun.lock", integrity: nil),
       Bibliothecary::Dependency.new(platform: "npm", name: "lodash", requirement: "4.17.21", type: "runtime", local: false, source: "bun.lock", integrity: "sha512-v2kDEe57lecTulaDIuNTPy3Ry4gLGJ6Z1O3vE1krgXZNrsQ+LFTGHVxVjcXPs17LhbZVGedAJv8XZ1tvj5FvSg=="),
       Bibliothecary::Dependency.new(platform: "npm", name: "prettier", requirement: "3.5.3", type: "development", local: false, source: "bun.lock", integrity: "sha512-QQtaxnoDJeAkDvDKWCLiwIXkTgRhwYDEQCghU9Z6q03iyek/rxRh/2lC3HB7P8sWT2xC/y5JDctPLBIGzHKbhw=="),
       Bibliothecary::Dependency.new(platform: "npm", name: "typescript", requirement: "5.8.2", type: "runtime", local: false, source: "bun.lock", integrity: "sha512-aJn6wq13/afZp/jT9QZmwEjDqqvSGp1VT5GVg+f/t6/oVyrgXM6BY1h9BRh/O5p3PlUPAe+WuiEZOmb/49RqoQ=="),
       Bibliothecary::Dependency.new(platform: "npm", name: "undici-types", requirement: "6.20.0", type: "runtime", local: false, source: "bun.lock", integrity: "sha512-Ny6QZ2Nju20vw1SRHe3d9jVu6gJ+4e3+MMpqu7pqE5HT6WsTSlce++GQmK5UXS8mzV8DSYHrQH+Xrf2jVcuKNg=="),
     ],
                                                                                           kind: "lockfile",
                                                                                           success: true,
                                                                                         })
  end

  describe "integrity extraction" do
    it "extracts integrity from pnpm-lock.yaml v5" do
      result = described_class.analyse_contents("pnpm-lock.yaml", load_fixture("pnpm-lockfile-version-5/pnpm-lock.yaml"))
      babel_types = result[:dependencies].find { |d| d.name == "@babel/types" }
      expect(babel_types.integrity).to eq("sha512-x0LvFTekgSX+83TI28Y9wYPUfzrnl2aT5+5QLnO6v7mSJYtEEevuDRN0F0uSHRk1G1IWZC43o00Y0xDDrpBGPQ==")
    end

    it "extracts integrity from pnpm-lock.yaml v6" do
      result = described_class.analyse_contents("pnpm-lock.yaml", load_fixture("pnpm-lockfile-version-6/pnpm-lock.yaml"))
      babel_types = result[:dependencies].find { |d| d.name == "@babel/types" }
      expect(babel_types.integrity).to eq("sha512-x0LvFTekgSX+83TI28Y9wYPUfzrnl2aT5+5QLnO6v7mSJYtEEevuDRN0F0uSHRk1G1IWZC43o00Y0xDDrpBGPQ==")
    end

    it "extracts integrity from pnpm-lock.yaml v9" do
      result = described_class.analyse_contents("pnpm-lock.yaml", load_fixture("pnpm-lockfile-version-9/pnpm-lock.yaml"))
      babel_types = result[:dependencies].find { |d| d.name == "@babel/types" }
      expect(babel_types.integrity).to eq("sha512-x0LvFTekgSX+83TI28Y9wYPUfzrnl2aT5+5QLnO6v7mSJYtEEevuDRN0F0uSHRk1G1IWZC43o00Y0xDDrpBGPQ==")
    end

    it "extracts integrity from yarn.lock v4" do
      result = described_class.analyse_contents("yarn.lock", load_fixture("yarn-v4-lockfile/yarn.lock"))
      js_tokens = result[:dependencies].find { |d| d.name == "js-tokens" }
      expect(js_tokens.integrity).to eq("10c0/e248708d377aa058eacf2037b07ded847790e6de892bbad3dac0abba2e759cb9f121b00099a65195616badcb6eca8d14d975cb3e89eb1cfda644756402c8aeed")
    end

    it "extracts integrity from package-lock.json v1" do
      result = described_class.analyse_contents("package-lock.json", load_fixture("npm-lockfile-version-1/package-lock.json"))
      find_versions = result[:dependencies].find { |d| d.name == "find-versions" }
      expect(find_versions.integrity).to eq("sha512-wgpWy002tA+wgmO27buH/9KzyEOQnKsG/R0yrcjPT9BOFm0zRBVQbZ95nRGXWMywS8YR5knRbpohio0bcJABxQ==")
    end
  end
end
