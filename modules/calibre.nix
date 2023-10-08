{config, ...}: let
  library = /var/lib/calibre-server;
  group = "library";
in {
  services.calibre-web = {
    inherit group;
    enable = true;
    listen = {
      ip = "0.0.0.0";
    };
    options = {
      calibreLibrary = library;
      enableKepubify = true;
      enableBookUploading = true;
    };
  };
  services.calibre-server = {
    enable = true;
    inherit group;
    auth = {
      enable = true;
      userDb = /var/lib/calibre-server/users.sqlite;
    };
  };
}
