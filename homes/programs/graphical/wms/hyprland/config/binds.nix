{ config
, pkgs
, ...
}: {
  wayland.windowManager.hyprland.settings = {
    "$MOD" = "SUPER";

    bindm = [
      "$MOD, mouse:272, movewindow"
      "$MOD, mouse:273, resizewindow"
    ];

    bind = [
      "$MOD,C,killactive,"
      "$MOD,M, exit,"
      "$MOD,V,togglefloating,"
      "$MOD,P,pseudo,"
      "$MOD,J,togglesplit,"
      "$MOD,F,fullscreen,"

      "$MOD, left, movefocus, l"
      "$MOD, right, movefocus, r"
      "$MOD, up, movefocus, u"
      "$MOD, down, movefocus, d"

      "$MOD,1, workspace, 1"
      "$MOD,2, workspace, 2"
      "$MOD,3, workspace, 3"
      "$MOD,4, workspace, 4"
      "$MOD,5, workspace, 5"
      "$MOD,6, workspace, 6"
      "$MOD,7, workspace, 7"
      "$MOD,8, workspace, 8"
      "$MOD,9, workspace, 9"

      "$MODSHIFT,1, movetoworkspace, 1"
      "$MODSHIFT,2, movetoworkspace, 2"
      "$MODSHIFT,3, movetoworkspace, 3"
      "$MODSHIFT,4, movetoworkspace, 4"
      "$MODSHIFT,5, movetoworkspace, 5"
      "$MODSHIFT,6, movetoworkspace, 6"
      "$MODSHIFT,7, movetoworkspace, 7"
      "$MODSHIFT,8, movetoworkspace, 8"
      "$MODSHIFT,9, movetoworkspace, 9"

      "$MOD,R,exec, tofi-drun --drun-launch=true"
      "$MOD,B,exec, firefox"
      "$MOD,O,exec, codium"
      "$MOD,Q,exec, kitty"
      "$MOD,S,exec, grim -g \"$(slurp -w 0 -d)\" - | wl-copy"
      "$MODCTRL,P, exec, hyprpicker -a"
      "$MOD,E,exec, emacs"
    ];

    binde = [
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",mouse:277, exec, echo \"unique stardewvally keyHold 46 100 sleep 100 keyPress 54 keyPress 111 keyPress 19 sleep 80 keyRelease 54 keyRelease 111 keyRelease 19\" > /tmp/domacro"
    ];
    bindl = [
      ",XF86AudioPlay, exec, playerctl play-pause"
      ",XF86AudioNext, exec, playerctl next"
      ",XF86AudioPrev, exec, playerctl previous"
    ];
  };
}
