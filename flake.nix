{
  description = "A flake for building ORYX from source using flakelight";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Pinning to a specific commit to ensure API stability.
    # You can remove the `rev` and `narHash` to go back to the latest.
    flakelight.url = "github:nix-community/flakelight/06521a6725f85db6467c398651e49ba8238cb6e0";
  };

  # This is the correct invocation pattern for this version of flakelight,
  # as seen in its README.md file. It uses flakelight as a functor.
  # The `./.` is a special attribute on the flakelight output that acts as the entrypoint.
  outputs = inputs@{ self, flakelight, ... }:
    flakelight ./. ({ lib, pkgs, self', ... }: {

      # 1. Define all packages under the `packages` attribute set.
      packages = {
        # The package definition is now a function that takes `pkgs` as an argument.
        oryx = pkgs: pkgs.rustPlatform.buildRustPackage rec {
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

          meta = with pkgs.lib; { # Use `pkgs.lib` provided by the functor
            description = "A TUI for sniffing network traffic";
            homepage = "https://github.com/pythops/oryx";
            license = licenses.mit;
            platforms = platforms.linux;
            maintainers = with maintainers; [ ]; # Add your GitHub handle here
          };
        };

        # 2. The default package is a function of `self'`.
        # `self'` refers to the final set of packages for the current system.
        default = self': self'.packages.oryx;
      };

      # 3. Define the development shell.
      # This is a function that takes the final package set (`self'`) and `pkgs`.
      devShells.default = { self', pkgs, ... }: pkgs.mkShell {
        # `inputsFrom` allows the shell to reuse all the build dependencies.
        inputsFrom = [ self'.packages.oryx ];
        # Add any extra development tools here.
        packages = [ pkgs.rust-analyzer ];
      };

      # 4. Define the formatter. This is a function that takes `pkgs`.
      formatter = pkgs: pkgs.nixpkgs-fmt;
    });
}
