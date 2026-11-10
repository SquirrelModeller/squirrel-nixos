{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkMerge concatMapStringsSep;
  enabledUsers = config.squirrelOS.users.enabled;

  # fzf-tab must come before zsh-autosuggestions, and zsh-syntax-highlighting must stay last.
  plugins = [
    {
      src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      file = "fzf-tab.plugin.zsh";
    }
    {
      src = "${pkgs.fzf}/share/fzf";
      file = "key-bindings.zsh";
    }
    {
      src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
      file = "zsh-autosuggestions.zsh";
    }
    {
      src = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
      file = "zsh-syntax-highlighting.zsh";
    }
  ];

  sourcePlugin = {
    src,
    file,
  }: ''
    if [[ -f "${src}/${file}" ]]; then
      source "${src}/${file}"
    fi
  '';

  userZshOrEmpty = u: let
    p = "${inputs.self}/users/${u}/zsh";
  in
    if builtins.pathExists p
    then builtins.readFile p
    else "";
in {
  config = {
    programs.zsh = {
      enable = true;
      enableCompletion = false;
    };

    # enableCompletion = false also stops NixOS linking /share/zsh, which site-functions
    # (nix, nixos-rebuild, nh, ...) depends on for the system fpath.
    environment.pathsToLink = ["/share/zsh"];
    environment.systemPackages = with pkgs; [
      eza
      fzf
      zsh-completions
      nix-zsh-completions
    ];

    hjem.users = mkMerge (map
      (u: {
        ${u}.files.".zshrc".text = ''
          ${userZshOrEmpty u}

          ${concatMapStringsSep "\n" sourcePlugin plugins}
        '';
      })
      enabledUsers);
  };
}
