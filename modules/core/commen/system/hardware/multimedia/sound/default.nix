{
  config,
  lib,
  pkgs,
  ...
}: {
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # I found that wpctl worked fine to set the default sound
  # I have not configured that yet though in these files
  # This is left here until i figure out how to properly configure the sound
  environment.etc."wireplumber/policy.lua.d/90-default-audio.lua".text = ''
    table.insert(alsa_monitor.rules, {
      matches = {
        {
          { "node.name", "equals", "alsa_output.usb-iFi__by_AMR__iFi__by_AMR__HD_USB_Audio_0003-00.analog-stereo" },
        },
      },
      apply_properties = {
        ["node.disabled"] = false,
        ["priority.session"] = 10000,
      }
    })
  '';
}
