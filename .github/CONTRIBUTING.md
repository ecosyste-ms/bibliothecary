# Contributing

Thanks for considering contributing to bibliothecary.

## Getting Started

1. Fork the repo
2. Run `bin/setup` to install dependencies
3. Run `bundle exec rspec` to run tests
4. Make your changes
5. Submit a pull request

## Running Benchmarks

```
bin/benchmark-lockfiles
```

## Adding a New Parser

1. Create `lib/bibliothecary/parsers/your_parser.rb`
2. Include `Bibliothecary::Analyser`
3. Define `self.mapping` with filename matchers and parser methods
4. Add tests in `spec/parsers/your_parser_spec.rb`
5. Add fixtures in `spec/fixtures/`
6. Update `README.md` with supported file types

## Questions

Open an issue on GitHub.
