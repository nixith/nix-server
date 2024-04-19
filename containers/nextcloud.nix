{
  pkgs,
  sops,
  config,
  ...
}: let
  host = "nextcloud";
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
}
