{config, ...}: {
  sops.secrets.freshrss = {
    owner = "freshrss";
  };
  services.freshrss = {
    passwordFile = config.sops.secrets.freshrss.path;
    baseUrl = "https://patchouli:80";
    enable = true;
    defaultUser = "admin";
  };
  services.nginx.virtualHosts."freshrss".listen = [
    {
      port = 2020;
      addr = "127.0.0.1";
    }
  ];

  services.rss-bridge = {
    enable = true;
    whitelist = ["*"];
  };
  services.nginx.virtualHosts."rss-bridge".listen = [
    {
      port = 2021;
      addr = "127.0.0.1";
    }
  ];
}
