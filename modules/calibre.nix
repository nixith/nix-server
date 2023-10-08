{config, ...}: let
  library = /var/lib/calibre-server;
  group = "library";
in {
  services.calibre-web = {
    inherit group;
    enable = true;
    user = "calibre";
    listen = {
      ip = "0.0.0.0";
    };
    options = {
      #calibreLibrary = library; #set imperatively due to nix copying paths
      enableKepubify = true;
      enableBookUploading = true;
    };
  };
  services.calibre-server = {
    enable = true;
    inherit group;
    user = "calibre";
    auth = {
      enable = true;
      userDb = /var/lib/calibre-server/users.sqlite;
    };
  };

  users.extraUsers."calibre" = {
    home = "/var/lib/calibre-server";
    group = "library";
    createHome = true;
    isSystemUser = true;
    homeMode = "776";
  };
}
