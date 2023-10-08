{config, ...}: {
  sops.secrets.freshrss = {
    owner = "freshrss";
  };
  services.freshrss = {
    passwordFile = config.sops.secrets.freshrss.path;
    baseUrl = "https://patchouli:2120";
    enable = true;
  };
}
