{
  config,
  lib,
  self,
  ...
}: {
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.talosvault.net";
      # Lets the iOS app receive instant pushes via ntfy.sh's APNs relay.
      upstream-base-url = "https://ntfy.sh";
      listen-http = ":2586";
      behind-proxy = true;
      auth-default-access = "deny-all";
    };
    # Holds NTFY_AUTH_USERS / NTFY_AUTH_TOKENS (see secrets/ntfy-env.age).
    environmentFile = config.age.secrets.ntfy-env.path;
  };

  age.secrets.ntfy-env.file = "${self}/secrets/ntfy-env.age";

  systemd.services.ntfy-sh.serviceConfig = {
    ProtectSystem = lib.mkForce "strict";
    ProtectHome = true;
    ProtectHostname = true;
    ProtectClock = true;
    ProtectProc = "invisible";
    ProcSubset = "pid";
    PrivateMounts = true;
    PrivateUsers = true;
    KeyringMode = "private";
    RemoveIPC = true;
    UMask = lib.mkForce "0077";
    LockPersonality = true;
    SystemCallArchitectures = "native";
    AmbientCapabilities = lib.mkForce [""];
    CapabilityBoundingSet = lib.mkForce [""];
    RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_NETLINK"];
    SystemCallFilter = ["@system-service" "~@privileged"];
    # The NAS pool, /boot, and the system D-Bus socket (ntfy never talks to D-Bus).
    InaccessiblePaths = ["/talos" "/boot" "/run/dbus"];
    # Inbound from iris over wg0, the LAN resolver, and ntfy.sh (APNs relay, IPv4 + IPv6).
    # ntfy.sh addresses were resolved on 2026-10-23.
    IPAddressDeny = "any";
    IPAddressAllow = [
      "10.0.0.1"
      "192.168.0.1"
      "159.203.148.75"
      "2604:a880:800:14:0:1:73c0:2000"
    ];
  };

  # Only reached through the iris reverse proxy over wg0.
  networking.firewall.interfaces.wg0.allowedTCPPorts = [2586];

  # The LAN router is allowed by IPAddressAllow so DNS works, but that allows every port.
  # Limit ntfy-sh to DNS (53) on the router, match by unit cgroup, so other services are unaffected.
  networking.firewall.extraCommands = ''
    iptables -A OUTPUT -m cgroup --path system.slice/ntfy-sh.service -d 192.168.0.1 -p udp --dport 53 -j ACCEPT
    iptables -A OUTPUT -m cgroup --path system.slice/ntfy-sh.service -d 192.168.0.1 -p tcp --dport 53 -j ACCEPT
    iptables -A OUTPUT -m cgroup --path system.slice/ntfy-sh.service -d 192.168.0.1 -j DROP
  '';
}
