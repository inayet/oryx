{
  description = "A flake for building ORYX from source using flakelight";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Add the flakelight library as an input
    flakelight.url = "github:nix-community/flakelight";
  };

  # The outputs function now uses flakelight to abstract away system logic
  outputs = { self, nixpkgs, flakelight }:
    flakelight.lib.simpleFlake {
      # 1. Tell flakelight where to get packages for each system
      pkgs = nixpkgs.legacyPackages;

      # 2. Define a package named 'oryx'
      # flakelight will automatically build this for each default system.
      oryx = { pkgs, ... }: pkgs.rustPlatform.buildRustPackage rec {
        pname = "oryx";
        version = "0.6.1";

        src = pkgs.fetchFromGitHub {
          owner = "pythops";
          repo = "oryx";
          rev = "v${version}";
          # This is a placeholder hash. You still need to get the correct one.
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };

        # This is also a placeholder hash you need to find.
        cargoSha256 = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [ pkgs.libpcap ];

        meta = with pkgs.lib; {
          description = "A TUI for sniffing network traffic";
          homepage = "https://github.com/pythops/oryx";
          license = licenses.mit;
          platforms = platforms.linux;
        };
      };

      # 3. Set the default package for `nix build` and `nix run`
      default = self.packages.oryx;
    };
}
