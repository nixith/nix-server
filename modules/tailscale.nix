{config, ...}: {
  services = {
    tailscale = {
      useRoutingFeatures = "both";
      enable = true;
      openFirewall = true;
      permitCertUid = "caddy";
      extraUpFlags = ["--accept-dns=false" "--ssh" "--accept-risk=lose-ssh" "--advertise-exit-node"];
    };
  };
  networking.firewall = {
    enable = true;
    trustedInterfaces = ["tailscale0"];
  };
}
