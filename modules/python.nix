{
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
}: {
  perSystem = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.pythonShell;

    workspace = uv2nix.lib.workspace.loadWorkspace {
      workspaceRoot = cfg.workspaceRoot;
    };

    overlay = workspace.mkPyprojectOverlay {
      sourcePreference = cfg.sourcePreference;
    };

    editableOverlay = workspace.mkEditablePyprojectOverlay {
      root = "$REPO_ROOT";
    };

    pythonSet =
      (pkgs.callPackage pyproject-nix.build.packages {
        python = cfg.python;
      })
      .overrideScope (lib.composeManyExtensions [
        pyproject-build-systems.overlays.default
        overlay
        editableOverlay
      ]);

    virtualenv = pythonSet.mkVirtualEnv "dev-env" workspace.deps.all;
  in {
    options.pythonShell = {
      workspaceRoot = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Root of the uv workspace (dir with pyproject.toml + uv.lock).";
      };

      python = lib.mkOption {
        type = lib.types.package;
        default = pkgs.python313;
        description = "Python interpreter used to build the environment.";
      };

      sourcePreference = lib.mkOption {
        type = lib.types.enum ["wheel" "sdist"];
        default = "wheel";
        description = "Prefer prebuilt wheels or build from sdist.";
      };

      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Extra packages added to the Python devShell.";
      };
    };

    config.devShells = lib.mkIf (cfg.workspaceRoot != null) {
      python = pkgs.mkShell {
        packages = [virtualenv pkgs.uv] ++ cfg.extraPackages;

        env = {
          UV_NO_SYNC = "1";
          UV_PYTHON = "${virtualenv}/bin/python";
          UV_PYTHON_DOWNLOADS = "never";
        };

        shellHook = ''
          unset PYTHONPATH
          export REPO_ROOT=$(git rev-parse --show-toplevel)
        '';
      };
    };
  };
}
