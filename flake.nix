{
  description = "Reusable flake-parts modules for project devShells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs = {
        pyproject-nix.follows = "pyproject-nix";
        uv2nix.follows = "uv2nix";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs: let
    # python.nix closes over uv2nix's inputs so downstream consumers only
    # need to import the flakeModule — not carry the uv2nix inputs themselves.
    pythonModule = import ./modules/python.nix {
      inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;
    };
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {system, ...}: {
        _module.args.pkgs = import inputs.nixpkgs {inherit system;};
      };

      imports = [
        ./modules/ocaml.nix
        pythonModule
      ];

      flake.flakeModules = {
        ocaml = ./modules/ocaml.nix;
        python = pythonModule;
      };
    };
}
