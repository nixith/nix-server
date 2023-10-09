{...}: {
  services.nginx = {
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;
  };

  virtualHosts."proxy" = {
    serverName = "proxy";
    reuseport = true;
    locations = {
      "/freshrss" = {
          proxyPass = "localhost:2020";
        }
    };
  };
}
