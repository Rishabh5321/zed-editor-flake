{
  description = "Flake with package defined in package.nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
        f {
          inherit system;
          pkgs = import nixpkgs { inherit system; };
        }
      );
    in
    {
      packages = forAllSystems ({ pkgs, ... }: {
        zed-editor = pkgs.callPackage ./packages/zed-editor { };
        zed-editor-preview = pkgs.callPackage ./packages/zed-editor-preview { };
        default = pkgs.callPackage ./packages/zed-editor { };
      });

      # Optional: uncomment to enable devShell
      # devShells = forAllSystems ({ pkgs, ... }: {
      #   default = pkgs.mkShell {
      #     buildInputs = [ pkgs.callPackage ./package.nix {} ];
      #   };
      # });
    };
}
