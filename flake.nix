{
  description = "A flake for building ORYX from source";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # A community helper for making flakes cleaner and multi-platform
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    # Use the helper to generate outputs for common systems (x86_64-linux, etc.)
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # The package is now available as `nix build .#oryx` or just `nix build`
        packages.oryx = pkgs.rustPlatform.buildRustPackage rec {
          pname = "oryx";
          version = "0.6.1";

          # Fetches the source code directly from the GitHub release tag
          src = pkgs.fetchFromGitHub {
            owner = "pythops";
            repo = "oryx";
            rev = "v${version}";
            # This is a placeholder hash. We will get the correct one in the steps below.
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

          # This hash ensures the Rust dependencies are exactly the same.
          # It's also a placeholder we will fix.
          cargoSha256 = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

          # Oryx needs these system libraries to build and run
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.libpcap ];

          meta = with pkgs.lib; {
            description = "A TUI for sniffing network traffic";
            homepage = "https://github.com/pythops/oryx";
            license = licenses.mit;
            platforms = platforms.linux; # This is now managed by flake-utils
            maintainers = [ ]; # You can add your GitHub handle here
          };
        };

        # Set our `oryx` package as the default for `nix build` and `nix run`
        packages.default = self.packages.${system}.oryx;
      });
}
