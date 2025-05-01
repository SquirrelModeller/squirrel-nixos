{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    userName = "Squirrel Modeller";
    userEmail = "squirrelmodeller@gmail.com";
  };
}
