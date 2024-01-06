{config, ...}: {
  services = {
    tailscale = {
      useRoutingFeatures = "both";
      enable = true;
      permitCertUid = "caddy";
      extraUpFlags = ["--accept-dns=false"];
    };
  };
  networking.firewall = {
    enable = true;
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };
}
