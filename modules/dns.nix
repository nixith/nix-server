{...}: {
  services.unbound = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      server = {
        interface = ["127.0.0.1"];
        port = "5335";
        do-ip4 = "yes";
        do-udp = "yes";
        do-tcp = "yes";
        harden-glue = "yes";
        edns-buffer-size = 1232;
        prefetch = true;
        private-address = [
          "192.168.0.0/16"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "10.0.0.0/8"
          "fd00::/8"
          "fe80::/10"
        ];
      };
      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "1.1.1.1"
            "8.8.8.8"
          ];
        }

        {
          name = "patchouli.me.";
          forward-addr = [
            "127.0.0.1"
          ];
        }
      ];
      #remote-control.control-enable = true;
    };
  };
}
