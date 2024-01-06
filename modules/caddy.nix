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
    virtualHosts."nixith.dev" = {
      #
      extraConfig = ''
         tls {
             dns cloudflare {env.CLOUDFLARE_API_TOKEN}
               resolvers 1.1.1.1
         }
        reverse_proxy localhost:8080
      '';
      #hostName = "freshrss";
    };
    # virtualHosts."calibre.patchouli.centaur-stargazer.ts.net" = {
    #   extraConfig = ''
    #     tls {
    #       get_certificate tailscale
    #     }
    #     reverse_proxy :8083
    #   '';
    #hostName = "freshrss";
    # };
  };
}
