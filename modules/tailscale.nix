{config, ...}: {
  services = {
    tailscale = {
      useRoutingFeatures = "both";
      enable = true;
      openFirewall = true;
      permitCertUid = "caddy";
      extraUpFlags = ["--accept-dns=false"];
    };
  };
  networking.firewall = {
    enable = true;
    trustedInterfaces = ["tailscale0"];
  };
}
