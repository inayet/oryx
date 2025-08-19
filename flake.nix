{
  description = "A flake for packaging ORYX";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # To lock to a specific version for full reproducibility, run:
    # nix flake lock --update-input nixpkgs
  };

  outputs = { self, nixpkgs }:
    let
      # 1. List of systems you want to support.
      # Add more if binaries for them are available.
      supportedSystems = [ "x86_64-linux" ];

      # 2. Helper function to generate outputs for each system.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # 3. Generate the package set for each supported system.
      oryxPackages = forAllSystems (system:
        let
          # Use the nixpkgs for the specific system being iterated over.
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # The package is now accessible as `oryx.packages.<system>.default`
          default = pkgs.stdenv.mkDerivation rec {
            pname = "oryx";
            version = "0.6.1";

            # Note: This binary is specific to x86_64-linux.
            # If you supported more systems, you'd need logic here
            # to fetch the correct binary for each `system`.
            src = pkgs.fetchurl {
              url = "https://github.com/pythops/oryx/releases/download/v${version}/oryx-x86_64-unknown-linux-musl";
              sha256 = "sha256-R6M43qLjiMFDgseGQrIGzTsdWO/wqt1/bgIFMGS+yTc=";
            };

            dontUnpack = true;

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              cp $src $out/bin/oryx
              chmod +x $out/bin/oryx
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "A TUI for sniffing network traffic";
              homepage = "https://github.com/pythops/oryx";
              license = licenses.mit;
              # The `platforms` attribute now reflects the supported systems.
              platforms = platforms.linux;
              maintainers = with maintainers; [ ]; # Good practice to add your handle
            };
          };
        });
    in
    {
      # Expose the packages under `packages.<system>.*`
      packages = oryxPackages;

      # Add a defaultPackage for convenience, so `nix build` works out-of-the-box.
      defaultPackage = forAllSystems (system: self.packages.${system}.default);
    };
}
