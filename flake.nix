{
  description = "A flake for building ORYX from source using flakelight";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight/06521a6725f85db6467c398651e49ba8238cb6e0";
  };

  outputs = inputs@{ self, flakelight, ... }:
    flakelight ./. ({ lib, pkgs, self', ... }:
      # Use a `let` binding to define the package derivation once.
      # This avoids code duplication and the circular reference that caused the error.
      let
        oryx-pkg = pkgs: pkgs.rustPlatform.buildRustPackage rec {
          pname = "oryx";
          version = "0.6.1";

          src = pkgs.fetchFromGitHub {
            owner = "pythops";
            repo = "oryx";
            rev = "v${version}";
            # NOTE: This is a placeholder hash. The first time you build,
            # Nix will fail and tell you the correct hash to put here.
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

          # NOTE: This is also a placeholder. The build will fail and provide
          # the correct hash for you to copy here.
          cargoSha256 = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.libpcap ];

          doCheck = true;

          meta = with pkgs.lib; {
            description = "A TUI for sniffing network traffic";
            homepage = "https://github.com/pythops/oryx";
            license = licenses.mit;
            platforms = platforms.linux;
            maintainers = with maintainers; [ ];
          };
        };
      in
      {
        # The `packages` set contains all your defined packages.
        packages = {
          # The main package, using the derivation from the `let` block.
          oryx = oryx-pkg;

          # The `default` package is a special name used by `nix build`.
          # By assigning the same derivation here, we make it the default.
          default = oryx-pkg;
        };

        # The dev shell can refer to the final package output.
        # `self'` here is correctly scoped and refers to the final flake outputs.
        devShells.default = { self', pkgs, ... }: pkgs.mkShell {
          inputsFrom = [ self'.packages.oryx ];
          packages = [ pkgs.rust-analyzer ];
        };

        formatter = pkgs: pkgs.nixpkgs-fmt;
      });
}
