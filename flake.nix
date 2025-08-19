{
  description = "A flake for building ORYX from source using flakelight";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight";
  };

  outputs = inputs@{ self, flakelight, ... }:
    flakelight ./. ({ lib, pkgs, ... }:
      let
        oryx-pkg = pkgs: pkgs.rustPlatform.buildRustPackage rec {
          pname = "oryx";
          version = "0.6.1";

          src = pkgs.fetchFromGitHub {
            owner = "pythops";
            repo = "oryx";
            rev = "v${version}";
            # STEP 1: Nix will tell you what to paste here.
            hash = "sha256-dnsQLKsvVuteNuGx1FLkv8F8dLDePFO32NfSEja+fhA=";
          };

          # STEP 2: After fixing the hash above, Nix will tell you what to paste here.
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
          oryx = oryx-pkg;
          default = oryx-pkg;
        };

        devShells.default = pkgs: {
          inputsFrom = [ (oryx-pkg pkgs) ];
          packages = [ pkgs.rust-analyzer ];
        };

        formatter = pkgs: pkgs.nixpkgs-fmt;
      });
}
