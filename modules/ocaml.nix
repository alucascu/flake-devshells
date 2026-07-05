{
  perSystem = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.ocamlShell = {
      ocamlPackages = lib.mkOption {
        type = lib.types.attrs;
        default = pkgs.ocamlPackages;
        defaultText = lib.literalExpression "pkgs.ocamlPackages";
        description = ''
          The OCaml package set the devShell is built from. Defaults to the
          nixpkgs default. To pick a specific compiler, point this at a
          versioned set, e.g. `pkgs.ocaml-ng.ocamlPackages_5_3` or
          `pkgs.ocaml-ng.ocamlPackages_latest`.
        '';
      };

      dune = lib.mkOption {
        type = lib.types.package;
        default = pkgs.dune_3;
        defaultText = lib.literalExpression "pkgs.dune_3";
        description = ''
          The Dune package added to the devShell. Defaults to `pkgs.dune_3`.
          Override to pin a specific version, e.g. `pkgs.dune_3.overrideAttrs`.
        '';
      };

      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Extra packages added to the OCaml devShell.";
      };
    };

    config.devShells.ocaml = pkgs.mkShell {
      packages = with config.ocamlShell.ocamlPackages;
        [
          ocaml
          findlib
          ocaml-lsp
          utop
          odoc
        ]
        ++ [pkgs.ocamlformat config.ocamlShell.dune]
        ++ config.ocamlShell.extraPackages;
    };
  };
}
