{...}: {
  sops.secrets.freshrss = {
    owner = "freshrss";
  };
  services.freshrss = {
    baseUrl = "https://patchouli:2120";
    enable = true;
  };
}
