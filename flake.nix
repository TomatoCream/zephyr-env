{
  description = "Zephyr development environment for ZMK (Sofle/nice_nano)";

  inputs = {
    # Using a slightly older nixpkgs to ensure python310 is available as required by zephyr-nix
    # NixOS 23.11 branch handles this well
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    
    # flake-parts for modular configuration
    flake-parts.url = "github:hercules-ci/flake-parts";
    
    # zephyr-nix provides the Zephyr SDK and Python environment
    zephyr-nix.url = "github:nix-community/zephyr-nix";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";
    
    # ZMK specifically requires Zephyr v3.5.0 at the moment for their latest main
    zephyr.url = "github:zephyrproject-rtos/zephyr/v3.5.0";
    zephyr.flake = false;
    zephyr-nix.inputs.zephyr.follows = "zephyr";
  };

  outputs = inputs @ { self, nixpkgs, flake-parts, zephyr-nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      
      perSystem = { config, self', inputs', pkgs, system, ... }: let
        # Access the zephyr-nix packages for our system
        zephyr = zephyr-nix.packages.${system};
        
        # Build the minimal SDK with only the target we need: arm-zephyr-eabi for nRF52840 (nice_nano)
        # Using version 0.16.x which is recommended for newer ZMK
        zephyrSdk = zephyr.sdk-0_16.override {
          targets = [ "arm-zephyr-eabi" ];
        };
      in {
        devShells.default = pkgs.mkShell {
          name = "zmk-dev-shell";
          
          # Native CI/CD/build tools
          packages = [
            # ZMK framework tools
            zephyrSdk                 # The arm-zephyr-eabi toolchain
            zephyr.pythonEnv          # Python environment with Zephyr requirements (including west)
            zephyr.hosttools-nix      # Host tools re-packaged with nixpkgs (better compatibility than binary hosttools)
            
            # Standard build tools
            pkgs.cmake
            pkgs.ninja
            pkgs.dfu-util             # Often needed for flashing nice_nano
            pkgs.ccache               # Good for build caching
            pkgs.git                  # Needed by west
            pkgs.just                 # For easy command execution
          ];

          # Establish environment variables that west and Zephyr SDK expect
          shellHook = ''
            export ZEPHYR_TOOLCHAIN_VARIANT="zephyr"
            
            # Point Zephyr to our Nix-managed SDK
            export ZEPHYR_SDK_INSTALL_DIR="${zephyrSdk}"
            
            echo "⌨️  ZMK Zephyr environment initialized!"
            echo "   • MCU Target: nRF52840 (arm-zephyr-eabi)"
            echo "   • Board: nice_nano"
            echo ""
            echo "To initialize ZMK:"
            echo "  west init -l app/"
            echo "  west update"
            echo ""
            echo "To build firmware:"
            echo "  west build -s app -b nice_nano -- -DSHIELD=sofle_left"
          '';
        };
      };
    };
}
