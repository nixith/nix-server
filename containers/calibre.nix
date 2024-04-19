{
  pkgs,
  sops,
  config,
  ...
}: let
  host = "calibre-web";
  host-backend = "calibre-server";
  library = "/var/lib/calibre/library";
in {
  # This feels gross but we're going to run two containers instead of one and
  # use talscale to manage the DNS since blocky doesn't seem to want to handle
  # rewrites as of now
  sops.secrets = {
    tailscaleService.owner = "root";
  };
  #calibre-web
  containers."${host}" = {
    bindMounts = {
      # should hoooopefully work
      "${config.sops.secrets.tailscaleService.path}" = {
        isReadOnly = true;
      };
      "${library}".isReadOnly = false;
    };
    enableTun = true;
    autoStart = true;
    # maybe use specialArgs to access secrets? Not sure if that's better or worse than rn
    config = {
      imports = [
        ./baseConfig.nix
      ];

      templates.baseConfig = {
        enable = true;
        hostname = "${host}";
        tsAuthKeyFile = "/run/secrets/tailscaleService";
      };

      # Service Start
      services.calibre-web = {
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
        calibreLibrary = library;
      };
      services.caddy = {
        enable = true;
        logFormat = "level INFO";
        virtualHosts."${host}.centaur-stargazer.ts.net" = {
          #
          extraConfig = ''
            reverse_proxy ${config.services.calibre-web.listen.port}:${config.services.calibre-web.listen.port}
          '';
        };
      };
    };
  };
  #calibre-server
  containers."${host-backend}" = {
    bindMounts = {
      "${config.sops.secrets.tailscaleService.path}" = {
        isReadOnly = true;
      };
      "${library}".isReadOnly = false;
    };
    enableTun = true;
    autoStart = true;
    # maybe use specialArgs to access secrets? Not sure if that's better or worse than rn
    config = {
      imports = [
        ./baseConfig.nix
      ];
      templates.baseConfig = {
        enable = true;
        hostname = "${host-backend}";
        tsAuthKeyFile = "/run/secrets/tailscaleService";
      };

      services.calibre-server = {
        enable = true;
        user = "calibre";
        host = "127.0.0.1";
        auth = {
          enable = true;
          userDb = /var/lib/calibre-server/users.sqlite;
        };
        libaries = [library];
        port = 8082;
      };

      services.caddy = {
        enable = true;
        logFormat = "level INFO";
        virtualHosts."${host-backend}.centaur-stargazer.ts.net" = {
          #
          extraConfig = ''
            reverse_proxy ${config.services.calibre-server.host}:${config.services.calibre-server.port}
          '';
          #hostName = "freshrss";
        };
      };
    };
  };
}
