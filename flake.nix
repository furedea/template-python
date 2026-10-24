{
  description = "";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages =
          (with pkgs; [
            commitlint
            deadnix
            ls-lint
            nixfmt
            statix
          ])
          ++ [
            (pkgs.callPackage ./nix/python.nix { })
            (pkgs.callPackage ./nix/uv.nix { })
            # lefthook before 2.1.6 runs hooks under a pty, which agent sandboxes deny.
            nixpkgs-unstable.legacyPackages.${system}.lefthook
          ];

        env = {
          UV_PYTHON_DOWNLOADS = "never";
          UV_PYTHON_PREFERENCE = "only-system";
        };

        shellHook = ''
          if [ -d .venv/bin ]; then
            export PATH="$PWD/.venv/bin:$PATH"
          fi
        '';
      };
    };
}
