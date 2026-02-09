{
  ...
}: {
  imports = [./default.nix];

  security.pam.services.sudo_local.touchIdAuth = true;
}
