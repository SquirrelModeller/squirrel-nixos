{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkMerge mapAttrsToList optionalString hasAttr concatStringsSep filter;
  enabledUsers = config.squirrelOS.users.enabled;

  zsh-async-src = pkgs.fetchFromGitHub {
    owner = "marlonrichert";
    repo = "z-async";
    rev = "5370537de80670b4a97e49cd253d15067709c0a6";
    sha256 = "0yl544misjpmfzipr1p68x28rlq5pp3fsvqsd6hl8sajhqb2ryml";
  };
  zsh-autocomplete-fixed = pkgs.zsh-autocomplete.overrideAttrs (old: {
    installPhase =
      old.installPhase
      + ''
        cp -R ${zsh-async-src} $out/share/zsh-autocomplete/z-async
      '';
  });

  plugins = {
    zsh-completions = {
      src = "${pkgs.zsh-completions}/share/zsh/site-functions";
    };
    nix-zsh-completions = {
      src = "${pkgs.nix-zsh-completions}/share/zsh/plugins/nix";
      file = "nix-zsh-completions.plugin.zsh";
    };
    zsh-autocomplete = {
      src = "${zsh-autocomplete-fixed}/share/zsh-autocomplete";
      file = "zsh-autocomplete.plugin.zsh";
    };
    zsh-syntax-highlighting = {
      src = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
      file = "zsh-syntax-highlighting.zsh";
    };
    fzf-tab = {
      src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      file = "fzf-tab.plugin.zsh";
    };
    zsh-fzf-history-search = {
      src = "${pkgs.zsh-fzf-history-search}/share/zsh-fzf-history-search";
      file = "zsh-fzf-history-search.plugin.zsh";
    };
    zsh-history-substring-search = {
      src = "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search";
      file = "zsh-history-substring-search.zsh";
    };
  };

  mkPlugins = plugins:
    concatStringsSep "\n" (
      mapAttrsToList
      (
        _: value: let
          hasFile = hasAttr "file" value;
        in
          concatStringsSep "\n" (filter (s: s != "") [
            (optionalString (!hasFile) ''fpath+=${value.src}'')
            (optionalString (hasFile && value.file != null) ''
              if [[ -f "${value.src}/${value.file}" ]]; then
                source "${value.src}/${value.file}"
              fi
            '')
          ])
      )
      plugins
    );

  userZshOrEmpty = u: let
    p = "${inputs.self}/users/${u}/zsh";
  in
    if builtins.pathExists p
    then builtins.readFile p
    else "";
in {
  config = {
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
      eza
    ];

    hjem.users = mkMerge (map
      (u: {
        ${u}.files.".zshrc".text = ''
          ${mkPlugins plugins}
          ${userZshOrEmpty u}
        '';
      })
      enabledUsers);
  };
}
