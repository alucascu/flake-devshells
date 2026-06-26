{
  description = "Reusable flake-parts modules for project devShells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {system, ...}: {
        _module.args.pkgs = import inputs.nixpkgs {inherit system;};
      };

      imports = [./modules/ocaml.nix];

      flake.flakeModules.ocaml = ./modules/ocaml.nix;
    };
}
