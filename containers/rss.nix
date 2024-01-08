{
  pkgs,
  sops,
  config,
  ...
}: let
  host = "rss";
  host-bridge = "rss-bridge";
in {
  # TODO: write module template out containers, exposing imports for sercices, caddy virtualhosts for forwarding

  # This feels gross but we're going to run two containers instead of one and
  # use talscale to manage the DNS since blocky doesn't seem to want to handle
  # rewrites as of now
  sops.secrets = {
    miniflux.owner = "root";
    tailscaleService.owner = "root";
  };
  #miniflux
  containers."${host}" = {
    bindMounts = {
      # should hoooopefully work
      "${config.sops.secrets.miniflux.path}" = {
        isReadOnly = true;
      };
      "${config.sops.secrets.tailscaleService.path}" = {
        isReadOnly = true;
      };
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
      services.miniflux = {
        enable = true;
        config = {
          CLEANUP_FREQUENCY = "48";
          CREATE_ADMIN = "1";
          LISTEN_ADDR = "127.0.0.1:8080";
          BASE_URL = "https://rss.centaur-stargazer.ts.net/";
        };
        # Service End
        adminCredentialsFile = "/run/secrets/miniflux";
      };
      services.caddy = {
        enable = true;
        logFormat = "level INFO";
        virtualHosts."${host}.centaur-stargazer.ts.net" = {
          #
          extraConfig = ''
            reverse_proxy localhost:8080
          '';
          #hostName = "freshrss";
        };
      };
    };
  };
  #rss-bridge
  containers."${host-bridge}" = {
    bindMounts = {
      "${config.sops.secrets.tailscaleService.path}" = {
        isReadOnly = true;
      };
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
        hostname = "${host-bridge}";
        tsAuthKeyFile = "/run/secrets/tailscaleService";
      };

      services.rss-bridge = {
        enable = true;
        whitelist = ["*"];
        #we'll do this until I can figure out caddy
        virtualHost = null;
        user = "caddy";
        group = "caddy";
      };
      environment.systemPackages = [pkgs.rss-bridge-cli];

      services.caddy = {
        enable = true;
        logFormat = "level INFO";
        virtualHosts."${host-bridge}.centaur-stargazer.ts.net" = {
          #
          extraConfig = ''
            root * ${pkgs.rss-bridge}
            php_fastcgi unix//run/phpfpm/rss-bridge.sock {
                index index.php
                root ${pkgs.rss-bridge}
                read_timeout 60s
                #split ^(.+\.php)(/.+)$
                #env SCRIPT_FILENAME $document_root$fastcgi_script_name
                env RSSBRIDGE_DATA /var/lib/rss-bridge
              }
            file_server
          '';
          #hostName = "freshrss";
        };
      };
    };
  };
}
