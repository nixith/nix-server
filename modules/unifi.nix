{pkgs, ...}: {
  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-4_4;
  };

  #https://help.ui.com/hc/en-us/articles/218506997-UniFi-Network-Required-Ports-Reference
  networking.firewall.allowedTCPPorts = [
    53
    8443
  ];
  networking.firewall.allowedUDPPorts = [
    53
    5514
    123
  ];
}
