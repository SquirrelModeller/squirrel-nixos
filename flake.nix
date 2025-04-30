{
  description = "Squirrel OS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    alejandra.url = "github:kamadorueda/alejandra/4.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    hyprpaper,
    alejandra,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.modeller = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./modules/options
        ./modules/core

        ./hardware-configuration.nix
        ./system.nix
        ./packages.nix

        ./users/squirrel.nix
        {
          modules.usrEnv.services.bar = "eww";

          modules.usrEnv.programs.launchers.tofi.enable = true;
          modules.usrEnv.programs.apps.vscodium.enable = true;
          modules.usrEnv.programs.apps.kitty.enable = true;
          modules.usrEnv.programs.apps.firefox.enable = true;
          modules.usrEnv.style.gtk.enable = true;
        }
        {
          networking.hostName = "modeller";
        }
        {
          programs.dconf.enable = true;
        }

        {
          environment.systemPackages = [alejandra.defaultPackage.${system}];
        }

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.squirrel = import ./homes/squirrel.nix;
          };
        }
      ];
    };
  };
}
