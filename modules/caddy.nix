{...}: {
  services.caddy = {
    enable = true;
    virtualHosts."proxy" = {
      listenAddresses = [
        "0.0.0.0"
        "::0"
      ];
      serverAliases = ["reverse-proxy"];
      extraConfig = ''

        handle /freshrss/* {
            reverse-proxy patchouli:2020
          }
      '';
    };
  };
}
