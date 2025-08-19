{
  description = "A flake for building ORYX from source using flakelight";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight/06521a6725f85db6467c398651e49ba8238cb6e0";
  };

  outputs = inputs@{ self, flakelight, ... }:
    flakelight ./. ({ lib, pkgs, ... }:
      # Use a `let` binding to define the package derivation as a function of `pkgs`.
      # This makes it reusable and avoids scoping issues.
      let
        oryx-pkg = pkgs: pkgs.rustPlatform.buildRustPackage rec {
          pname = "oryx";
          version = "0.6.1";

          src = pkgs.fetchFromGitHub {
            owner = "pythops";
            repo = "oryx";
            rev = "v${version}";
            # NOTE: This is a placeholder. The build will fail and give you the correct hash.
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

          # ---> THIS IS THE HASH YOU WILL NEED TO REPLACE <---
          # The build will fail and tell you the correct hash for your dependencies.
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
        packages = {
          oryx = oryx-pkg;
          default = oryx-pkg;
        };

        # FIX: The devShell definition for this version of flakelight
        # is a function that takes `pkgs` as an argument.
        devShells.default = pkgs: {
          # We get the build inputs by calling our package function with `pkgs`.
          inputsFrom = [ (oryx-pkg pkgs) ];
          packages = [ pkgs.rust-analyzer ];
        };

        formatter = pkgs: pkgs.nixpkgs-fmt;
      });
}
