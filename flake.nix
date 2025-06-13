{
  description = "A flake providing an up-to-date package for zed-editor";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    patched-nixpkgs.url = "github:TomaSajt/nixpkgs?ref=fetch-cargo-vendor-dup";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
  };

  outputs =
    inputs @ { flake-parts
    , nixpkgs
    , patched-nixpkgs
    , rust-overlay
    , crane
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem
      , moduleWithSystem
      , flake-parts-lib
      , ...
      }: {
        systems = with nixpkgs.lib.platforms; linux ++ darwin;

        perSystem =
          { system
          , pkgs
          , self'
          , inputs'
          , ...
          }:
          let
            rustBin = inputs.rust-overlay.legacyPackages.${system}.rust-bin;
          #   rustPlatform = inputs'.patched-nixpkgs.legacyPackages.rustPlatform;
          in
          {
            packages = {
              zed-editor = pkgs.callPackage ./packages/zed-editor { 
                crane = crane.mkLib pkgs;
                rustToolchain = rustBin.fromRustupToolchainFile ./rust-toolchain.toml;
              };
              zed-editor-fhs = self'.packages.zed-editor.passthru.fhs;

              zed-editor-preview = pkgs.callPackage ./packages/zed-editor-preview { 
                crane = crane.mkLib pkgs;
                rustToolchain = rustBin.fromRustupToolchainFile ./rust-toolchain.toml;
               };
              zed-editor-preview-fhs = self'.packages.zed-editor-preview.passthru.fhs;

              zed-editor-bin = pkgs.callPackage ./packages/zed-editor-bin { };
              zed-editor-bin-fhs = self'.packages.zed-editor-bin.passthru.fhs;

              zed-editor-preview-bin = pkgs.callPackage ./packages/zed-editor-preview-bin { };
              zed-editor-preview-bin-fhs = self'.packages.zed-editor-preview-bin.passthru.fhs;

              default = self'.packages.zed-editor;
            };

            apps = {
              zed-editor.program = "${self'.packages.zed-editor}/bin/zeditor";
              zed-editor-fhs.program = "${self'.packages.zed-editor-fhs}/bin/zeditor";
              zed-editor-preview.program = "${self'.packages.zed-editor-preview}/bin/zeditor";
              zed-editor-preview-fhs.program = "${self'.packages.zed-editor-preview-fhs}/bin/zeditor";
              zed-editor-bin.program = "${self'.packages.zed-editor-bin}/bin/zeditor";
              zed-editor-bin-fhs.program = "${self'.packages.zed-editor-bin-fhs}/bin/zeditor";
              zed-editor-preview-bin.program = "${self'.packages.zed-editor-preview-bin}/bin/zeditor";
              zed-editor-preview-bin-fhs.program = "${self'.packages.zed-editor-preview-bin-fhs}/bin/zeditor";
            };
          };
      }
    );
}
