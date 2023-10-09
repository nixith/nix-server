{config, ...}: {
  sops.secrets.freshrss = {
    owner = "freshrss";
  };
  services.freshrss = {
    passwordFile = config.sops.secrets.freshrss.path;
    baseUrl = "";
    enable = true;
    defaultUser = "admin";
    virtualHost = "freshrss.*";
  };
  #services.nginx.virtualHosts."freshrss.patchouli.taild56d5.ts.net/*".listen = [
  #  {
  #    port = 2020;
  #    addr = "0.0.0.0";
  #  }
  #];

  #services.nginx.virtualHosts."freshrss.patchouli.taild56d5.ts.net" = {
  #sslCertificateKey = "/var/patchouli.taild56d5.ts.net.key";
  #sslCertificate = "/var/patchouli.taild56d5.ts.net.crt";
  #};
  services.rss-bridge = {
    enable = true;
    whitelist = ["*"];
    virtualHost = "rss-bridge.*";
  };
  #services.nginx.virtualHosts."rss-bridge".listen = [
  #  {
  #    port = 2021;
  #    addr = "0.0.0.0";
  #  }
  #];
}
ryan@patch
