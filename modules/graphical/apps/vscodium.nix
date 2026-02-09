{
  config,
  lib,
  pkgs,
  getUserDotfiles,
  ...
}: let
  inherit (lib) mkIf mkMerge;

  enabledUsers = config.squirrelOS.users.enabled;
  inherit (pkgs.stdenv) isDarwin;

  getVSCodiumConfigPath = username:
    if isDarwin
    then "/Users/${username}/Library/Application Support/VSCodium/User"
    else ".config/VSCodium/User";

  getVSCodiumSettings = username: let
    dotfiles = getUserDotfiles username;
    settingsPath = ".config/VSCodium/User/settings.json";
  in
    if builtins.hasAttr settingsPath dotfiles
    then dotfiles.${settingsPath}
    else null;

  mkDarwinVSCodiumConfig = username: let
    settings = getVSCodiumSettings username;
    configPath = getVSCodiumConfigPath username;
  in
    mkIf (isDarwin && settings != null) {
      hjem.users.${username}.files."${configPath}/settings.json" = settings;
    };
in {
  config = mkMerge [
    {
      programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      environment.systemPackages = with pkgs; [
        nil
        nixpkgs-fmt
        qt6.qtdeclarative
        (pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = with pkgs.vscode-extensions; [
            jnoortheen.nix-ide
            ms-python.python
            ms-toolsai.jupyter
            ms-toolsai.jupyter-keymap
            ms-toolsai.jupyter-renderers
            mkhl.direnv
            eamodio.gitlens
            yzhang.markdown-all-in-one
            usernamehw.errorlens
            tomoki1207.pdf
          ];
        })
      ];

      programs.bash.enable = true;
      programs.zsh.enable = true;
    }

    (mkMerge (map mkDarwinVSCodiumConfig enabledUsers))
  ];
}
