{lib, ...}: {
  services.resolved = {
    enable = false;
    extraConfig = ''
      ReadEtcHosts=yes
      #DNSStubListenerExtra=100.88.114.3
      DNSStubListener=no
    '';
  };

  #networking.networkmanager.dns = "systemd-resolved";
  #
  # networking.extraHosts = ''
  #   100.88.114.3 patchouli.ts.net
  #   100.88.114.3 calibre.patchouli.ts.net
  #   100.88.114.3 freshrss.patchouli.ts.net
  #   100.88.114.3 rss-bridge.patchouli.ts.net
  # '';

  #services.dnsmasq = {
  #	enable = true;
  #	settings = {
  #		server = ["1.1.1.1" "9.9.9.9"];
  #		};
  #    	extraConfig =
  #	''
  #	#domain-needed
  #	#bogus-priv
  #	#no-resolv
  #	server=1.1.1.1
  #	server=9.9.9.9
  #
  #	address=/patchouli.ts.net/100.88.114.3
  #	address=/patchouli.centaur-stargazer.ts.net/100.88.114.3
  #
  #	listen-address=::1,127.0.0.1,100.88.114.3,10.10.42.52
  #	bind-interfaces

  #	cache-size=10000
  #	log-queries
  #	log-facility=/tmp/ad-block.log
  #	local-ttl=300

  #conf-file=/etc/nixos/assets/hosts-blocklists/domains.txt
  #addn-hosts=/etc/nixos/assets/hosts-blocklists/hostnames.txt
  #    '';
  #   };
  services.blocky = {
    enable = true;
    settings = {
      upstream = {
        default = [
          #"100.100.100.100" #tailscale
          "1.1.1.1"
          "1.0.0.1"
          "8.8.8.8"
          "9.9.9.9"
        ];
      };
      upstreamTimeout = "2s";
      startVerifyUpstream = false;
      connectIPVersion = "dual";
      customDNS = {
        customTTL = "1h";
        filterUnmappedTypes = true;
        rewrite = {
          "tsn" = "ts.net";
          #   "calibre.centaur-stargazer.ts.net" = "patchouli.centaur-stargazer.ts.net"; #interferes with tailscale ssl certs with caddy
        };
        #rewrite = {"ts.net" = "centaur-stargazer.ts.net";}; #interferes with tailscale ssl certs with caddy
        mapping = {
          "patchouli.centaur-stargazer.ts.net" = "100.88.114.3";
          "rss-bridge.centaur-stargazer.ts.net" = "100.103.49.37";
          #"patchouli" = "100.88.114.3";
          "calibre.ts.net" = "100.88.114.3";
          "nix.dev" = "100.88.114.3";
        };
      };
      blocking = {
        blackLists = {
          ads = [
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "http://sysctl.org/cameleon/hosts"
            "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
            "# inline definition with YAML literal block scalar style\n# hosts format\nsomeadsdomain.com\n"
          ];
          special = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts"];
        };
        whiteLists = null;
        clientGroupsBlock = {
          default = ["ads" "special"];
          "laptop*" = ["ads"];
        };
        blockType = "zeroIp";
        blockTTL = "1m";
        refreshPeriod = "4h";
        downloadTimeout = "4m";
        downloadAttempts = 5;
        downloadCooldown = "10s";
        startStrategy = "fast";
      };
      caching = {
        minTime = "5m";
        maxTime = "30m";
        maxItemsCount = 0;
        prefetching = true;
        prefetchExpires = "2h";
        prefetchThreshold = 5;
        prefetchMaxItemsCount = 0;
        cacheTimeNegative = "30m";
      };
      clientLookup = {
        upstream = "100.100.100.100";
        singleNameOrder = [2 1];
        clients = null;
      };
      bootstrapDns = [
        "tcp+udp:1.1.1.1"
        "https://1.1.1.1/dns-query"
        {
          upstream = "https://dns.digitale-gesellschaft.ch/dns-query";
          ips = ["185.95.218.42"];
        }
      ];
      hostsFile = {
        filePath = "/etc/hosts";
        hostsTTL = "60m";
        refreshPeriod = "30m";
        filterLoopback = true;
      };
      ports = {
        dns = ["127.0.0.1:53" "100.88.114.3:53"]; #localhost & tailscale
        tls = 853;
        http = 4000;
      };
      log = {
        level = "info";
        format = "text";
        timestamp = true;
        privacy = false;
      };
      ede = {enable = true;};
    };
  };
  networking = {
    nameservers = ["127.0.0.1" "::1" "100.100.100.100"];
    # If using dhcpcd:
    #dhcpcd.extraConfig = "nohook resolv.conf";
    # If using NetworkManager:
    networkmanager.dns = "none";
    #resolvconf.useLocalResolver = true;
  };
}
