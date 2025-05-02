{
  description = "Squirrel OS";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      flake = {
        nixosConfigurations.modeller = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/options
            ./settings.nix
            ./modules/core
            ./hardware-configuration.nix
            ./system.nix
            ./packages.nix
            ./users/squirrel.nix
            ./hosts
          ];
        };
      };
    };

  inputs = {
    systems.url = "github:nix-systems/default-linux";

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    xdg-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";
    hyprpicker.url = "github:hyprwm/hyprpicker";

    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs = {
        hyprlang.follows = "hyprland/hyprlang";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
    };

    alejandra.url = "github:kamadorueda/alejandra/4.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
  };
}
