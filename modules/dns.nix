{...}: {
  services.resolved = {
    enable = true;
    extraConfig = ''
      ReadEtcHosts=yes
      DNSStubListenerExtra=100.88.114.3
    '';
  };

  networking.networkmanager.dns = "systemd-resolved";

  networking.extraHosts = ''
    100.88.114.3 patchouli.ts.net
    100.88.114.3 calibre.patchouli.ts.net
    100.88.114.3 freshrss.patchouli.ts.net
    100.88.114.3 rss-bridge.patchouli.ts.net
  '';
}
