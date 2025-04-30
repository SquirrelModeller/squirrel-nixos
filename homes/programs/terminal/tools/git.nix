{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    userName = "Squirrel Modeller";
    userEmail = "squirrelmodeller@gmail.com";

    extraConfig = {
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };
}
