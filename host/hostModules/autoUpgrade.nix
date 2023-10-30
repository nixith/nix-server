{...}: {
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";

    allowReboot = true;
    rebootWindow = {
      upper = "05:00";
      lower = "01:00";
    };
    persistent = true;
    operation = "switch";
    flake = "github:bromine1/nix-server";
  };
}
