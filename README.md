# Squirrel NixOS Config

My personal NixOS configuration.

## Cool things

- Both NixOS and nix-darwin are supported. Each host declares its target platform in a `system` file, and the flake automatically routes it to `nixosConfigurations` or `darwinConfigurations`. Modules that differ per platform (e.g. Firefox, VSCodium, security) split into `nixos.nix` / `darwin.nix` siblings with a shared `default.nix`.
- Hosts are auto-discovered from `hosts/*`, no manual registration needed.
- Users are auto-discovered from `users/*`. Each host can set which users are active:
  ```nix
  # hosts/<host>/configuration.nix
  {
    squirrelOS.users.enabled = [ "squirrel" "guest" ];
  }
  ```
- A `ctx` object (platform, roles, capabilities) is passed to every user package definition. This is the only host-level context in the config, it keeps macOS support clean and prevents graphical or workstation packages from leaking onto servers.
- There are declarative per-user services from `users/<name>/services.nix`.
- Theming is handled by [matugen](https://github.com/InioX/matugen), which generates a consistent color scheme across all applications from a wallpaper.

## Philosophy

I avoid heavy custom abstractions. Most modules here are standard NixOS options with minimal wrapping, which keeps them loosely coupled and easy to reference or borrow from other configurations without pulling in a bespoke option framework.

Automation is a big focus for me. That's why hosts and users are auto-discovered: I can just add a new host folder and build it, without ever having to hardcode any paths. I find that process very satisfying.

This repository is designed with multiple users in mind. I don't want to force system-wide applications, especially since I want to use this configuration for workstations, laptops, and servers - each with their own needs and users.

## Credits

- Greek naming convention taken from [Nyx](https://github.com/NotAShelf/nyx).
- Thanks to the entire Hyprland community for helping me!
