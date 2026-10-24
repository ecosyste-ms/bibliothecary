require 'spec_helper'

describe Bibliothecary::Parsers::Actions do
  it 'has a platform name' do
    expect(described_class.platform_name).to eq('actions')
  end

  it 'parses dependencies from node actions.yml' do
    expect(described_class.analyse_contents('action.yml', load_fixture('action.yml'))).to eq({
      platform: "actions",
      path: "action.yml",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "actions", name: "dist/index.js", requirement: "node16", type: "javascript", source: "action.yml")
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'parses dependencies from docker actions.yml' do
    expect(described_class.analyse_contents('action.yml', load_fixture('docker-action.yml'))).to eq({
      platform: "actions",
      path: "action.yml",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "actions", name: "Dockerfile", requirement: "*", type: "docker", source: "action.yml")
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'parses dependencies from composite actions.yml' do
    expect(described_class.analyse_contents('action.yml', load_fixture('composite-action.yml'))).to eq({
      platform: "actions",
      path: "action.yml",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "actions", name: "aws-actions/configure-aws-credentials", requirement: "v1", type: "composite", source: "action.yml"),
        Bibliothecary::Dependency.new(platform: "actions", name: "actions/setup-node", requirement: "v2", type: "composite", source: "action.yml")
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'parses dependencies from workflow.yml' do
    expect(described_class.analyse_contents('.github/workflows/ci.yml', load_fixture('workflow.yml'))).to eq({
      platform: "actions",
      path: ".github/workflows/ci.yml",
      dependencies: [
        Bibliothecary::Dependency.new(platform: "actions", name: "actions/bin/shellcheck", requirement: "master", type: "composite", source: ".github/workflows/ci.yml"),
        Bibliothecary::Dependency.new(platform: "actions", name: "docker://replicated/dockerfilelint", requirement: "*", type: "composite", source: ".github/workflows/ci.yml"),
        Bibliothecary::Dependency.new(platform: "actions", name: "actions/docker/cli", requirement: "master", type: "composite", source: ".github/workflows/ci.yml"),
        Bibliothecary::Dependency.new(platform: "actions", name: "docker://node", requirement: "6", type: "composite", source: ".github/workflows/ci.yml"),
        Bibliothecary::Dependency.new(platform: "actions", name: "redis", requirement: "5", type: "docker", source: ".github/workflows/ci.yml"),
        Bibliothecary::Dependency.new(platform: "actions", name: "postgres", requirement: "10", type: "docker", source: ".github/workflows/ci.yml")
      ],
      kind: 'manifest',
      project_name: nil,
      success: true
    })
  end

  it 'parses docker references with registry ports and digests' do
    action = <<~YAML
      name: Fixture
      runs:
        using: composite
        steps:
          - uses: docker://alpine:3.20
          - uses: docker://localhost:5000/img:1
          - uses: docker://localhost:5000/img
          - uses: docker://alpine@sha256:abc123
          - uses: docker://ghcr.io/o/img:2@sha256:def456
    YAML
    expect(described_class.parse_manifest(action).dependencies.map { |d| [d.name, d.requirement] }).to eq([
      ["docker://alpine", "3.20"],
      ["docker://localhost:5000/img", "1"],
      ["docker://localhost:5000/img", "*"],
      ["docker://alpine", "sha256:abc123"],
      ["docker://ghcr.io/o/img", "2"]
    ])

    docker_action = "name: Fixture\nruns:\n  using: docker\n  image: docker://localhost:5000/img@sha256:abc123\n"
    expect(described_class.parse_manifest(docker_action).dependencies.map { |d| [d.name, d.requirement] }).to eq([
      ["docker://localhost:5000/img", "sha256:abc123"]
    ])

    workflow = <<~YAML
      on: push
      jobs:
        test:
          runs-on: ubuntu-latest
          services:
            db:
              image: localhost:5000/postgres:16
            cache: redis@sha256:abc123
            optional:
              image: ''
            unset:
              ports: ['80']
            expression:
              image: ${{ matrix.redis && 'redis:7' || '' }}
    YAML
    expect(described_class.analyse_contents('.github/workflows/ci.yml', workflow)[:dependencies].map { |d| [d.name, d.requirement] }).to eq([
      ["localhost:5000/postgres", "16"],
      ["redis", "sha256:abc123"]
    ])
  end

  it 'matches valid manifest filepaths' do
    expect(described_class.match?('action.yml')).to be_truthy
    expect(described_class.match?('action.yaml')).to be_truthy

    expect(described_class.match?('.github/workflows/ci.yml')).to be_truthy
    expect(described_class.match?('.github/workflows/build.yaml')).to be_truthy
    expect(described_class.match?('.github/workflows/test/build.yaml')).to be_truthy
  end

  it "doesn't match invalid manifest filepaths" do
    expect(described_class.match?('test/foo/aaction.yml')).to be_falsey
  end
end
