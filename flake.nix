{
  description = "A flake for building ORYX from source using flakelight";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight/06521a6725f85db6467c398651e49ba8238cb6e0";
  };

  outputs = inputs@{ self, flakelight, ... }:
    flakelight ./. ({ lib, pkgs, ... }:
      let
        # This is the standard package set that links against glibc.
        pkgs-glibc = pkgs;
        # This is the special package set that links against musl for static binaries.
        pkgs-musl = pkgs.pkgsStatic;

        # The package definition is now a function that accepts a specific `pkgs` set.
        # This allows us to reuse the same definition for both glibc and musl builds.
        oryx-pkg = pkgs: pkgs.rustPlatform.buildRustPackage rec {
          pname = "oryx";
          version = "0.6.1";

          src = pkgs.fetchFromGitHub {
            owner = "pythops";
            repo = "oryx";
            rev = "v${version}";
            hash = "sha256-dnsQLKsvVuteNuGx1FLkv8F8dLDePFO32NfSEja+fhA=";
          };

          # You will need to get this hash by running `nix build .#oryx-static`
          # or `nix build .#oryx`. The hash is usually the same for both.
          cargoSha256 = "";

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
          # The default, dynamically linked package.
          oryx = oryx-pkg pkgs-glibc;
          default = oryx-pkg pkgs-glibc;

          # The new, statically linked package.
          oryx-static = oryx-pkg pkgs-musl;
        };

        devShells.default = pkgs: {
          # The dev shell will use the standard (glibc) version.
          inputsFrom = [ (oryx-pkg pkgs) ];
          packages = [ pkgs.rust-analyzer ];
        };

        formatter = pkgs: pkgs.nixpkgs-fmt;
      });
}
