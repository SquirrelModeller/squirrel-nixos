{ pkgs, ... }: {
  config = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    environment.systemPackages = with pkgs; [
      vulkan-tools
      vulkan-loader
      radeontop
      libva
      libva-vdpau-driver
      libvdpau-va-gl
    ];

    environment.variables.AMD_VULKAN_ICD = "RADV";

    #Blender HIP compatability
    systemd.tmpfiles.rules = [
      "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
    ];
  };
}
