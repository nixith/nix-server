{
  config,
  pkgs,
  self,
  system,
  ...
}: {
  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = config.sops.secrets.cloudflare.path;
    AmbientCapabilities = "cap_net_bind_service";
    CapabilityBoundingSet = "cap_net_bind_service";
  };
  sops.secrets.cloudflare.owner = "caddy";

  services.caddy = {
    enable = true;
    package = pkgs.callPackage ../packages/myCaddy.nix {
      plugins = [
        "github.com/caddy-dns/cloudflare"
      ];
    };
    globalConfig = ''
      debug
    '';
    logFormat = "level INFO";
    virtualHosts."patchouli.nixith.dev" = {
      # have to set rss-bridge as root for now, waiting on subdomains from tailscale
      #
      extraConfig = ''
         tls {
             dns cloudflare {env.CLOUDFLARE_API_TOKEN}
         }
        reverse_proxy /rss/* localhost:8080
        reverse_proxy :8083
        reverse_proxy /calibre/lib/* :8082
        php_fastcgi unix//run/phpfpm/rss-bridge.sock
      '';
      #hostName = "freshrss";
    };
    virtualHosts."calibre.patchouli.centaur-stargazer.ts.net" = {
      extraConfig = ''
        tls {
          get_certificate tailscale
        }
        reverse_proxy :8083
      '';
      #hostName = "freshrss";
    };
  };
}
