{
  perSystem = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.ocamlShell.extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages added to the OCaml devShell.";
    };

    config.devShells.ocaml = pkgs.mkShell {
      packages = with pkgs.ocamlPackages;
        [
          ocaml
          findlib
          ocaml-lsp
          utop
          odoc
        ]
        ++ [pkgs.ocamlformat pkgs.dune_3] ++ config.ocamlShell.extraPackages;
    };
  };
}
