{ pkgs, ... }: {
  config = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [ pkgs.amdvlk ];
    };

    environment.systemPackages = with pkgs; [
      vulkan-tools
      vulkan-loader
      radeontop
      libva
      vaapiVdpau
      libvdpau-va-gl
    ];

    environment.variables.AMD_VULKAN_ICD = "RADV";

    #Blender HIP compatability
    systemd.tmpfiles.rules = [
      "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
    ];
  };
}
