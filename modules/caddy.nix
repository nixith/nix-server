{config, ...}: {
  services.caddy = {
    enable = true;
    globalConfig = ''
      debug
    '';
    logFormat = "level INFO";
    virtualHosts."patchouli.centaur-stargazer.ts.net" = {
      extraConfig = ''
         	tls {
        	get_certificate tailscale
        }
        reverse_proxy /rss/* :8080
        reverse_proxy /calibre/web/* :8083
        reverse_proxy /calibre/lib/* :8082
      '';
      #hostName = "freshrss";
    };
  };
}
