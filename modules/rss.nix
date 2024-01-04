{config, ...}: {
  # sops.secrets.freshrss = {
  #   owner = "freshrss";
  # };
  # services.freshrss = {
  #   passwordFile = config.sops.secrets.freshrss.path;
  #   baseUrl = "";
  #   enable = true;
  #   defaultUser = "admin";
  #   # virtualHost = "freshrss.*";
  #   virtualHost = null;
  # };
  #services.nginx.virtualHosts."freshrss.patchouli.taild56d5.ts.net/*".listen = [
  #  {
  #    port = 2020;
  #    addr = "0.0.0.0";
  #  }
  #];

  sops.secrets.miniflux = {
    #owner = "miniflux";
  };
  services.miniflux = {
    enable = true;
    config = {
      CLEANUP_FREQUENCY = "48";
      CREATE_ADMIN = "1";
      LISTEN_ADDR = "127.0.0.1:8080";
      BASE_URL = "https://patchouli.centaur-stargazer.ts.net/rss/";
    };
    adminCredentialsFile = config.sops.secrets.miniflux.path;
  };

  #services.nginx.virtualHosts."freshrss.patchouli.taild56d5.ts.net" = {
  #sslCertificateKey = "/var/patchouli.taild56d5.ts.net.key";
  #sslCertificate = "/var/patchouli.taild56d5.ts.net.crt";
  #};
  services.rss-bridge = {
    enable = true;
    whitelist = ["*"];
    #virtualHost = "rss-bridge.*";
    virtualHost = null;
    user = "miniflux";
  };
  #services.nginx.virtualHosts."rss-bridge".listen = [
  #  {
  #    port = 2021;
  #    addr = "0.0.0.0";
  #  }
  #];
}
