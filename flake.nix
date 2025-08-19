{
  description = "A flake for building ORYX from source using flakelight";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight";
  };

  # The `outputs` function is given all the inputs as arguments.
  # The `@inputs` pattern captures all of them into a single attrset called `inputs`.
  outputs = { self, ... }@inputs:
    # `mkFlake` is the main helper from flakelight.
    # It takes a configuration set and returns the final flake outputs.
    inputs.flakelight.lib.mkFlake {
      # FIX: Pass the `self` and the entire `inputs` set to flakelight.
      # It needs this to access nixpkgs and other inputs correctly.
      inherit self inputs;

      # Define the 'oryx' package for each system.
      # flakelight automatically passes `pkgs` for the correct system here.
      oryx = { pkgs, ... }: pkgs.rustPlatform.buildRustPackage rec {
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

        # System libraries needed for building and running.
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [ pkgs.libpcap ];

        # Run `cargo test` during the build.
        doCheck = true;

        meta = with pkgs.lib; {
          description = "A TUI for sniffing network traffic";
          homepage = "https://github.com/pythops/oryx";
          license = licenses.mit;
          platforms = platforms.linux;
          maintainers = with maintainers; [ ]; # Add your GitHub handle here
        };
      };

      # Set the default package for `nix build` and `nix run`.
      # `self'` here refers to the final, evaluated flake outputs for a given system.
      default = { self', ... }: self'.packages.oryx;

      # Define the development shell.
      devShells.default = { pkgs, self', ... }: pkgs.mkShell {
        # Inherit all the build dependencies from the `oryx` package.
        inputsFrom = [ self'.packages.oryx ];
        # Add any extra tools you want for development.
        packages = with pkgs; [
          rust-analyzer # For better IDE support
        ];
      };

      # Define the formatter for `nix fmt`.
      formatter = { pkgs, ... }: pkgs.nixpkgs-fmt;
    };
}
