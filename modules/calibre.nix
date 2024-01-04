{config, ...}: let
  library = /var/lib/calibre-server;
  group = "library";
in {
  users.groups.library = {};
  services.calibre-web = {
    inherit group;
    enable = true;
    user = "calibre";
    listen = {
      ip = "127.0.0.1";
    };
    options = {
      #calibreLibrary = library; #set imperatively due to nix copying paths
      enableKepubify = true;
      enableBookUploading = true;
    };
  };
  # TODO: make nixpkgs commit to expose [url prefixes](https://manual.calibre-ebook.com/server.html#id12)
  # services.calibre-server = {
  #   enable = true;
  #   inherit group;
  #   user = "calibre";
  #   auth = {
  #     enable = true;
  #     userDb = /var/lib/calibre-server/users.sqlite;
  #   };
  #   port = 8082;
  # };

  users.extraUsers."calibre" = {
    home = "/var/lib/calibre-server";
    group = "library";
    createHome = true;
    isSystemUser = true;
    homeMode = "776";
  };
}
