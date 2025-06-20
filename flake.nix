{
  description = "Simple zed-editor flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
        f {
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };
        }
      );
    in
    {
      packages = forAllSystems ({ pkgs, ... }:
        let
          rustPlatform = pkgs.makeRustPlatform {
            cargo = pkgs.rust-bin.stable.latest.default;
            rustc = pkgs.rust-bin.stable.latest.default;
          };
        in
        {
          zed-editor = pkgs.callPackage ./packages/zed-editor {
            inherit rustPlatform;
          };
          zed-editor-bin = pkgs.callPackage ./packages/zed-editor-bin { };
          zed-editor-fhs = self.packages.${pkgs.system}.zed-editor.fhs;
          zed-editor-bin-fhs = self.packages.${pkgs.system}.zed-editor-bin.fhs;
          zed-editor-preview = pkgs.callPackage ./packages/zed-editor-preview {
            inherit rustPlatform;
          };
          zed-editor-preview-bin = pkgs.callPackage ./packages/zed-editor-preview-bin { };
          zed-editor-preview-fhs = self.packages.${pkgs.system}.zed-editor-preview.fhs;
          zed-editor-preview-bin-fhs = self.packages.${pkgs.system}.zed-editor-preview-bin.fhs;
          default = pkgs.callPackage ./packages/zed-editor { };
        }
      );

      # Optional: uncomment to enable devShell
      # devShells = forAllSystems ({ pkgs, ... }: {
      #   default = pkgs.mkShell {
      #     buildInputs = [ pkgs.callPackage ./package.nix {} ];
      #   };
      # });
    };
}
