{
  config,
  lib,
  inputs,
  pkgs,
  user,
  ...
}: let
  update =
    pkgs.writeShellScriptBin "update"
    ''
      ${pkgs.sudo}/bin/sudo nixos-rebuild switch --flake github:bromine1/nix-server#server
    '';
in {
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "patchouli";
    wireless.enable = false;
    networkmanager.enable = true;
  };
  # Set your time zone.
  time.timeZone = "America/New_York";
  environment.systemPackages = with pkgs; [
    # To manage the actual user configuration
    neovim
    git
    auto-cpufreq
    curl
    coreutils
    gh
    fish
    update
  ];

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services = {
    auto-cpufreq.enable = true;
  };

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

  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://cache.garnix.io"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];

      auto-optimise-store = true; # Optimise symlinks
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "@wheel"];
      sandbox = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 5d";
    };
  };

  #Define a user account.
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "library"]; # Enable ‘sudo’ for the user.
    hashedPassword = "$6$8a7Hgdgv5zOp6w5u$Kro/9wAni3mtXOGhc8bWxYCa8aijTqowdA1lXucHiLxtct/9ZGAr9bzwePv5cfjnQSUG2YOvJOMYpVF0j75G91"; #TODO fix with sops-nix
    openssh.authorizedKeys.keys = pkgs.lib.remove [] (builtins.split "\n" (builtins.readFile inputs.sshKeys));
  };

  # mount filesystems correctly

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
