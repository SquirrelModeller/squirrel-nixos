# Squirrel NixOS Config

*This README is still a work in progress. Likewise, the entire Nix config is heavily a work in progress.*

My personal NixOS configuration.

## Cool things

- Hosts are auto-discovered from `hosts/*` and turned into `nixosConfigurations.<host>`.
- Users are auto-discovered from `users/*`. Each host can set which users are active:
  ```
  # hosts/<host>/configuration.nix
  {
    squirrelOS.users.enabled = [ "squirrel" "guest" ];
  }
  ```
- There are declarative per-user services from `users/<name>/services.nix`.

## Philosophy
I aim to keep my NixOS setup as minimal as possible when it comes to external dependencies.

I used to use Home Manager; however, it felt too bloated to me, with lots of obscure variables. I use Hjem now, which is much simpler and just writes the necessary symlinks directly. It's still a dependency, but a lightweight and fast one.

Automation is a big focus for me. That's why hosts and users are also auto-discovered: I can just add a new host folder and build it, without ever having to hardcode any paths. I find that process very satisfying.

I'm still learning Nix, and I know there's a lot of room for improvement. I'm probably making some major mistakes here, and I'd love to learn from them. I'm open to suggestions anytime.

This repository is designed with multiple users in mind. I don't want to force system-wide applications, especially since I want to use this configuration for workstations, laptops, and servers - each with their own needs and users.

## Work in progress

Currently, I'm working on integrating Wallust for theme syncing across all applications. It should make my Nix files less tightly coupled, while still allowing me to have a consistent look everywhere.

## Credits

- Greek naming convention taken from [Nyx](https://github.com/NotAShelf/nyx).
- Thanks to the entire Hyprland community for helping me!

## Contributions

See [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
