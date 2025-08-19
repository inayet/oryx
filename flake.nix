{
  description = "A flake for building ORYX from source using flakelight";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight";
  };

  # --- CORRECTED LINE ---
  # `outputs` is now assigned directly to `mkFlake`.
  # flakelight handles creating the function that receives the inputs.
  outputs =inputs@ {flakelight,nixpkgs,...}:
   flakelight.lib.mkFlake {
    # 1. Tell flakelight where to get packages for each system
    # `nixpkgs` is an input and is automatically available here.
    pkgs = nixpkgs.legacyPackages;

    # 2. Define the 'oryx' package
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

      # --- BEST PRACTICE: Enable checks ---
      # This will run `cargo test` during the build to ensure correctness.
      doCheck = true;

      meta = with pkgs.lib; {
        description = "A TUI for sniffing network traffic";
        homepage = "https://github.com/pythops/oryx";
        license = licenses.mit;
        platforms = platforms.linux;
        # --- BEST PRACTICE: Add maintainers ---
        maintainers = with maintainers; [ ]; # Add your GitHub handle here
      };
    };

    # 3. Set the default package for `nix build` and `nix run`
    # `self` is also an input and is automatically available.
    default = self.packages.oryx;

    # --- BEST PRACTICE: Add a development shell ---
    # Provides an environment for working on the code with `nix develop`
    devShells.default = { pkgs, ... }: pkgs.mkShell {
      # Inherit all the build dependencies from the `oryx` package
      inputsFrom = [ self.packages.oryx ];
      # Add any extra tools you want for development
      packages = with pkgs; [
        rust-analyzer # For better IDE support
      ];
    };

    # --- BEST PRACTICE: Add a formatter ---
    # Allows you to format all Nix code in the repo with `nix fmt`
    formatter = { pkgs, ... }: pkgs.nixpkgs-fmt;
  };
}
