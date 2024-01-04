{config, ...}: {
  services = {
    tailscale = {
      useRoutingFeatures = "both";
      enable = true;
      permitCertUid = "caddy";
    };
  };
  networking.firewall = {
    enable = true;
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };
}
