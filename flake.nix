{
  description = "nixith's server config";

  nixConfig = {
    # allow building without passing flags on first run
    extra-experimental-features = "nix-command flakes";
    # Add me to trusted users
    trusted-users = ["root" "@wheel"];
    builders-use-substitutes = true;

    # Grab binaries faster from sources
    substituters = [
      "https://cache.nixos.org/"
      "https://cache.garnix.io"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" #Me, Prism Launcher,
    ];
    http-connections = 0; #No limit on number of connections

    # nix store optimizations
    auto-optimise-store = true;
    allowUnfree = true;
    accept-flake-config = true;
    sandbox = false;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";

    nixos-hardware = {url = "github:NixOS/nixos-hardware/";};

    sshKeys = {
      url = "https://github.com/bromine1.keys";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    sops-nix,
    flake-utils,
    nixos-hardware,
    ...
  } @ inputs: let
    user = "ryan";

    serviceModules = [
      ./modules/tailscale.nix
      #./modules/calibre.nix #leave disabled until proxy buisness is figured out
      ./modules/rss.nix
      #./modules/nginx.nix
      ./modules/caddy.nix
      #./modules/adguard.nix
      ./modules/dns.nix
    ];
    commonHardware = [
      sops-nix.nixosModules.sops
      ./host/confiuration.nix
      ./host/hostModules/secrets.nix
      ./host/hostModules/autoUpgrade.nix
    ];
    specialArgs = {inherit inputs user sops-nix self;};
  in {
    nixosConfigurations = {
      server = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};

        sshKeys = pkgs.lib.remove [] (builtins.split "\n" (builtins.readFile inputs.sshKeys));
        modules =
          [
            ./host/hardware-confiuration.nix
          ]
          ++ serviceModules
          ++ commonHardware;

        specialArgs = {inherit inputs user sops-nix self pkgs system;};
      };
      oracleServer = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};

        sshKeys = pkgs.lib.remove [] (builtins.split "\n" (builtins.readFile inputs.sshKeys));
        modules =
          [
            ./host/oracle-hardware-configuration.nix
          ]
          ++ serviceModules
          ++ commonHardware;

        specialArgs = {inherit inputs user sops-nix self pkgs system;};
      };
    };
    #packages.${system}.caddy = pkgs.callPackage ./packages/myCaddy.nix { };
  };
}
