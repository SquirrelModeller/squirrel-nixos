{pkgs, ...}: {
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.pipewire.wireplumber.enable = true;

  # pactl CLI (used by e.g. Steam's voice chat to configure audio devices) —
  # pipewire's pulse protocol layer doesn't ship the client binary itself.
  environment.systemPackages = [pkgs.pulseaudio];
}
