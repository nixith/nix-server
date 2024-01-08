{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.templates.baseConfig;
in {
  options.templates.baseConfig = {
    enable = mkEnableOption "base config";

    hostname = mkOption {
      type = types.str;
    };

    tsAuthKeyFile = mkOption {
      type = types.path;
    };
  };
  config = mkIf cfg.enable {
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    system.stateVersion = "23.11";

    networking = {
      hostName = cfg.hostname;
      wireless.enable = false;
      networkmanager.enable = false;
      firewall = {
        enable = true;
      };
      # Needs private networking
      # Use systemd-resolved inside the container
      # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
      useHostResolvConf = mkForce false;
      # STATE_DIRECTORY=/var/lib/tailscale/tailscaled-tt_rss
      # $ sudo mkdir -p ${STATE_DIRECTORY}
      # $ sudo env STATE_DIRECTORY=${STATE_DIRECTORY} tailscaled --statedir=${STATE_DIRECTORY} --socket=${STATE_DIRECTORY}/tailscaled.sock --port=0 --tun=user
      # $ sudo tailscale --socket=${STATE_DIRECTORY}/tailscaled.sock up --auth-key=tskey-key-MYSERVICE_KEY_FROM_TAILSCALE_ADMIN_CONSOLE --hostname=MYSERVICE --reset
    };
    services.tailscale = {
      enable = true;
      permitCertUid = "caddy";
      openFirewall = true;
      interfaceName = "userspace-networking";
      #extraUpFlags = "-socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055"; #hopefully this works, if not we need to modify how systemd boots tailscaled
      extraUpFlags = ["--accept-dns"];
      authKeyFile = mkIf (cfg.tsAuthKeyFile != null) cfg.tsAuthKeyFile;
    };
    # have to modify service file to get socket and http proxies
    systemd.services.tailscale.serviceConfig.Environment =
      [
        "PORT=${toString config.services.tailscale.port}"
        ''"FLAGS=--tun ${lib.escapeShellArg config.services.tailscale.interfaceName} -socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055"''
        # -sock5 & #outbound-http added by me, otherwise taken from nixpkgs service file
      ]
      ++ (lib.optionals (config.services.tailscale.permitCertUid != null) [
        "TS_PERMIT_CERT_UID=${config.services.tailscale.permitCertUid}"
      ]);

    environment.variables = {
      ALL_PROXY = "socks5://localhost:1055/";
      HTTP_PROXY = "http://localhost:1055/";
      http_proxy = "http://localhost:1055/";
    };
    services.resolved = {
      enable = true;
      extraConfig = ''
        Domains=~.
        DNSStubListener=no
      '';
    };
  };
}
