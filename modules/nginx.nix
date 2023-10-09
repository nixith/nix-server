{...}: {
  services.nginx = {
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    defaultHTTPListenPort = 80;
    defaultSSLListenPort = 443;
    #recommendedZstdSettings = true;

    #virtualHosts."proxy" = {
    #  serverName = "proxy";
    #  reuseport = true;
    #  locations = {
    #    "/freshrss" = {
    #      proxyPass = "http://0.0.0.0:2020";
    #    };
    #  };
    #
    #  locations = {
    #    "/rss-bridge" = {
    #      proxyPass = "http://0.0.0.0:2021";
    #    };
    #  };
    #};
  };
}
