{ pkgs, ... }:
{
  # I use systemd for starting wallpapers, shells and so on.
  systemd.user.targets."hyprland-session" = {
    description = "Hyprland session anchor";
    after = [ "graphical-session.target" "default.target" ];
    wants = [ "graphical-session.target" ];
    wantedBy = [ "default.target" ];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
}
