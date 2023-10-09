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
}
