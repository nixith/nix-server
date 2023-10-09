{...}: {
  services.unbound = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      server = {
        interface = ["127.0.0.1"];
      };
      forward-zone = [
        {
          name = "patchouli.me.";
          forward-addr = [
            "127.0.0.1"
          ];
        }
      ];
      remote-control.control-enable = true;
    };
  };
}
