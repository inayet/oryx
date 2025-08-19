{
  # Description of the flake
  description = "A flake for packaging ORYX";

  # Define flake inputs (dependencies)
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Pin to a specific Nixpkgs channel for reproducibility
  };

  # Define flake outputs
  outputs = {
    self,
    nixpkgs,
  }: {
    # Define a package for the default system (x86_64-linux)
    packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.stdenv.mkDerivation rec {
      pname = "oryx";
      version = "0.6.1";

      # Download the pre-built ORYX binary from the GitHub release
      src = nixpkgs.legacyPackages.x86_64-linux.fetchurl {
        url = "https://github.com/pythops/oryx/releases/download/v${version}/oryx-x86_64-unknown-linux-musl";
        # You MUST replace the following with the actual SHA256 hash of the binary file
        # To get the SHA256 hash, download the file and run `sha256sum oryx-x86_64-unknown-linux-musl`
        sha256 = "sha256-R6M43qLjiMFDgseGQrIGzTsdWO/wqt1/bgIFMGS+yTc=";
      };

      # Add this line to skip the unpack phase
      dontUnpack = true;

      # Installation phase
      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/oryx
        chmod +x $out/bin/oryx
      '';

      # Additional information (optional)
      meta = with nixpkgs.legacyPackages.x86_64-linux.lib; {
        description = "TUI for sniffing network traffic";
        homepage = "https://github.com/pythops/oryx";
        license = licenses.mit;
        platforms = platforms.linux;
      };
    };
  };
}
