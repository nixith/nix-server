{config, ...}: let
  library = /var/lib/calibreLibrary;
  libraryGroup = "library";
in {
  services.calibre-web = {
    enable = true;
    listen = {
      ip = "0.0.0.0";
    };
    group = libraryGroup;
    options = {
      calibreLibrary = library;
      enableKepubify = true;
      enableBookUploading = true;
    };
  };
  services.calibre-server = {
    enable = true;
    group = libraryGroup;
    libraries = [
      library
    ];
    auth = {
      enable = true;
      userDb = /lib/var/calibre-server/users.sqlite;
    };
  };
}
