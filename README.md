# flake-devshells

Reusable [flake-parts](https://flake.parts) modules for language-specific
project `devShell`s. Import a module into your own flake to get a ready-made
development shell — with the language toolchain, LSP, formatter, and common
tooling already wired up — plus a few options for customization.

## Modules

| Module         | devShell   | Provides                                                                    |
| -------------- | ---------- | --------------------------------------------------------------------------- |
| `ocaml.nix`    | `ocaml`    | `ocaml`, `findlib`, `ocaml-lsp`, `utop`, `odoc`, `ocamlformat`, `dune_3`    |
| `python.nix`   | `python`   | A [uv2nix](https://github.com/pyproject-nix/uv2nix)-built virtualenv + `uv` |

## Usage

Each module is exposed under `flake.flakeModules`. Import it into your own
`flake-parts` flake and configure it through its options.

### OCaml

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-devshells.url = "github:<you>/flake-devshells";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [inputs.flake-devshells.flakeModules.ocaml];

      perSystem = {pkgs, ...}: {
        # Optional: add packages on top of the defaults.
        ocamlShell.extraPackages = [pkgs.ocamlPackages.ppx_deriving];
      };
    };
}
```

Then:

```sh
nix develop .#ocaml
```

#### Options

| Option                     | Type              | Default | Description                             |
| -------------------------- | ----------------- | ------- | --------------------------------------- |
| `ocamlShell.extraPackages` | `listOf package`  | `[]`    | Extra packages added to the OCaml shell |

### Python

The Python module builds a virtualenv from a [uv](https://docs.astral.sh/uv/)
workspace using `uv2nix`, and provides an editable install of the project so
your source is imported live.

Because it depends on `uv2nix`, `pyproject-nix`, and `pyproject-build-systems`,
it is imported as a function that takes those inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-devshells.url = "github:<you>/flake-devshells";

    pyproject-nix.url = "github:pyproject-nix/pyproject.nix";
    uv2nix.url = "github:pyproject-nix/uv2nix";
    pyproject-build-systems.url = "github:pyproject-nix/build-system-pkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      imports = [
        (import "${inputs.flake-devshells}/modules/python.nix" {
          inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;
        })
      ];

      perSystem = {pkgs, ...}: {
        pythonShell.workspaceRoot = ./.;
        # pythonShell.python = pkgs.python312;         # optional
        # pythonShell.sourcePreference = "sdist";      # optional
        # pythonShell.extraPackages = [pkgs.ruff];     # optional
      };
    };
}
```

The `python` devShell is only defined once `pythonShell.workspaceRoot` is set,
which must point at a directory containing `pyproject.toml` and `uv.lock`.

```sh
nix develop .#python
```

The shell sets `UV_NO_SYNC=1` and `UV_PYTHON_DOWNLOADS=never` so `uv` uses the
Nix-built interpreter rather than syncing or downloading its own.

#### Options

| Option                       | Type                    | Default          | Description                                             |
| ---------------------------- | ----------------------- | ---------------- | ------------------------------------------------------- |
| `pythonShell.workspaceRoot`  | `nullOr path`           | `null`           | Root of the uv workspace (`pyproject.toml` + `uv.lock`) |
| `pythonShell.python`         | `package`               | `pkgs.python313` | Python interpreter used to build the environment        |
| `pythonShell.sourcePreference` | `enum ["wheel" "sdist"]` | `"wheel"`      | Prefer prebuilt wheels or build from sdist              |
| `pythonShell.extraPackages`  | `listOf package`        | `[]`             | Extra packages added to the Python shell                |

## Development

This flake imports `ocaml.nix` directly and exposes it as
`flake.flakeModules.ocaml`. The `python.nix` module lives in `modules/` and is
consumed as shown above.

```sh
nix flake check
```
