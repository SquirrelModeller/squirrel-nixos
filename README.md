# Squirrel NixOS Config
*This README is still WIP. Likewise the entire Nix config is heavily in WIP*


My person NixOS configuration.

## Cool things

Hosts are auto-discovered from hosts/* and turned into nixosConfigurations.\<host\>.

Users are auto-discovered from users/*. Each host can set which users are active:
```
# hosts/<host>/configuration.nix
{
  squirrelOS.users.enabled = [ "squirrel" "guest" ]
}
```

There are declarative per-user services from users/\<name\>/services.nix.


## Credits
Greek naming convention taken from [Nyx](https://github.com/NotAShelf/nyx).

Thanks to the entire Hyprland community for helping me!

## Contributions

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
