{
  description = "A flake for building ORYX from source using flakelight";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight";
  };

  # The entire `outputs` attribute is assigned to the result of `mkFlake`.
  # The `inputs` argument provides access to `nixpkgs`, `self`, etc.
  outputs = inputs:
    inputs.flakelight.lib.mkFlake {
      # 1. Pass the necessary inputs to flakelight.
      # It needs `nixpkgs` to find packages and `self` to reference outputs.
      inherit (inputs) nixpkgs self;

      # 2. Define the 'oryx' package.
      # flakelight provides `pkgs` automatically.
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

        # System libraries needed for building and running
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

      # 3. Set the default package for `nix build` and `nix run`.
      default = { self, ... }: self.packages.oryx;

      # 4. Define the development shell.
      devShells.default = { pkgs, self, ... }: pkgs.mkShell {
        # Inherit all the build dependencies from the `oryx` package.
        inputsFrom = [ self.packages.oryx ];
        # Add any extra tools you want for development.
        packages = with pkgs; [
          rust-analyzer # For better IDE support
        ];
      };

      # 5. Define the formatter for `nix fmt`.
      formatter = { pkgs, ... }: pkgs.nixpkgs-fmt;
    };
}
