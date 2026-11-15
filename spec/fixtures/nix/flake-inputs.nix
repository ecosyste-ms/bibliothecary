{
  description = "Flake using top-level and attribute-set inputs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.import-cargo = {
    type = "github";
    owner = "edolstra";
    repo = "import-cargo";
  };
  inputs.fenix = {
    type = "github";
    owner = "nix-community";
    repo = "fenix";
    ref = "monthly";
  };
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };
  inputs.crane = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:ipetkov/crane";
  };

  outputs = { self, nixpkgs, import-cargo, fenix, crane }: {
    packages = { };
  };
}
