{
  description = "A flake for building ORYX from source using flakelight";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight/06521a6725f85db6467c398651e49ba8238cb6e0";
  };

  outputs = inputs@{ self, flakelight, ... }:
    flakelight ./. ({ lib, pkgs, ... }:
      let
        pkgs-glibc = pkgs;
        pkgs-musl = pkgs.pkgsStatic;

        oryx-pkg = pkgs: pkgs.rustPlatform.buildRustPackage rec {
          pname = "oryx";
          version = "0.6.1";

          src = pkgs.fetchFromGitHub {
            owner = "pythops";
            repo = "oryx";
            rev = "v${version}";
            hash = "sha256-dnsQLKsvVuteNuGx1FLkv8F8dLDePFO32NfSEja+fhA=";
          };

          cargoSha256 = "sha256-0000000000000000000000000000000000000000000000000000";

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
          oryx = oryx-pkg pkgs-glibc;
          default = oryx-pkg pkgs-glibc;
          oryx-static = oryx-pkg pkgs-musl;
        };

        devShells.default = {
          inputsFrom = [ (oryx-pkg pkgs) ];
          packages = [ pkgs.rust-analyzer ];
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
