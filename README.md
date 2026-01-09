# Bibliothecary

Dependency manifest parsing library for https://github.com/ecosyste-ms 

This is a maintained fork of the original [Bibliothecary](https://github.com/librariesio/bibliothecary) gem, with support for additional manifest formats and bug fixes.

## Installation

Requires Ruby 3.4 or above.

Add this line to your application's Gemfile:

```ruby
gem "ecosystems-bibliothecary", git: "https://github.com/ecosyste-ms/bibliothecary.git", require: "bibliothecary"
```

And then execute:

```shell
bundle install
```

## Usage

Identify package manager manifests from a list of files:

```ruby
Bibliothecary.identify_manifests(['package.json', 'README.md', 'index.js']) #=> 'package.json'
```

Parse a manifest file for it's dependencies:

```ruby
Bibliothecary.analyse_file 'bower.json', File.open('bower.json').read
```

Search a directory for manifest files and parse the contents:

```ruby
Bibliothecary.analyse('./')
```

All available config options are in: https://github.com/ecosyste-ms/bibliothecary/blob/master/lib/bibliothecary/configuration.rb

## Supported package manager file formats

- Actions
  - action.yml
  - action.yaml
  - .github/workflows/\*.yml
  - .github/workflows/\*.yaml
- Anaconda
  - environment.yml
  - environment.yaml
- BentoML
  - bentofile.yaml
- Bower
  - bower.json
- Cargo
  - Cargo.toml
  - Cargo.lock
- Carthage
  - Cartfile
  - Cartfile.private
  - Cartfile.resolved
- Clojars
  - project.clj
- CocoaPods
  - Podfile
  - \*.podspec
  - Podfile.lock
  - \*.podspec.json
- Cog
  - cog.yaml
- Conan
  - conanfile.py
  - conanfile.txt
  - conan.lock
- CPAN
  - META.json
  - META.yml
  - cpanfile
  - cpanfile.snapshot
  - Makefile.PL
  - Build.PL
- CRAN
  - DESCRIPTION
  - renv.lock
- Deno
  - deno.json
  - deno.jsonc
  - deno.lock
- Docker
  - docker-compose\*.yml
  - Dockerfile
- Dub
  - dub.json
  - dub.sdl
- DVC
  - dvc.yaml
- Elm
  - elm-package.json
  - elm_dependencies.json
  - elm-stuff/exact-dependencies.json
- Go
  - go.mod
  - go.sum
  - glide.yaml
  - glide.lock
  - Godeps/Godeps.json
  - Godeps
  - vendor/manifest
  - vendor/vendor.json
  - Gopkg.toml
  - Gopkg.lock
  - go-resolved-dependencies.json
- Hackage
  - \*.cabal
  - \*cabal.config
  - stack.yaml.lock
- Haxelib
  - haxelib.json
- Hex
  - mix.exs
  - mix.lock
  - gleam.toml
  - manifest.toml
- Homebrew
  - Brewfile
  - Brewfile.lock.json
- Julia
  - REQUIRE
- LuaRocks
  - \*.rockspec
- Maven
  - ivy.xml
  - pom.xml
  - build.gradle
  - build.gradle.kts
  - gradle-dependencies-q.txt
  - maven-resolved-dependencies.txt
  - sbt-update-full.txt
  - maven-dependency-tree.txt
  - maven-dependency-tree.dot
  - gradle.lockfile
  - verification-metadata.xml
- Meteor
  - versions.json
- MLflow
  - MLmodel
- Nimble
  - \*.nimble
- Nix
  - flake.nix
  - flake.lock
  - nix/sources.json
  - npins/sources.json
- npm
  - package.json
  - package-lock.json
  - npm-shrinkwrap.json
  - yarn.lock
  - pnpm-lock.yaml
  - bun.lock
  - npm-ls.json
- Nuget
  - Project.json
  - Project.lock.json
  - packages.lock.json
  - packages.config
  - \*.nuspec
  - \*.csproj
  - paket.lock
  - project.assets.json
  - \*.deps.json
- Ollama
  - Modelfile
- Packagist
  - composer.json
  - composer.lock
- Pub
  - pubspec.yaml
  - pubspec.lock
- PyPi
  - setup.py
  - requirements\*.txt
  - requirements\*.pip
  - requirements\*.in
  - requirements.frozen
  - Pipfile
  - Pipfile.lock
  - pyproject.toml
  - poetry.lock
  - uv.lock
  - pylock.toml
  - pdm.lock
  - pip-resolved-dependencies.txt
  - pip-dependency-graph.json
- RubyGems
  - Gemfile
  - Gemfile.lock
  - gems.rb
  - gems.locked
  - \*.gemspec
- Shards
  - shard.yml
  - shard.lock
- Swift
  - Package.swift
  - Package.resolved
- Vcpkg
  - vcpkg.json
  - _generated-vcpkg-list.json

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version:
* in `CHANGELOG.md`, move the changes under `"Unreleased"` into a new section with your version number
* bump and commit the version number in `version.rb` in the `main` branch
* and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ecosyste-ms/bibliothecary. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
