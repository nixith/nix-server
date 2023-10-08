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
    nixos-hardware,
    ...
  } @ inputs: let
    user = "ryan";

    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages."${system}";

    lib = pkgs.lib;

    sshKeys = lib.remove [] (builtins.split "\n" (builtins.readFile inputs.sshKeys));

    serviceModules = [
      ./modules/tailscale.nix
      ./modules/calibre.nix
      ./modules/spotify.nix
    ];
  in {
    nixosConfigurations = {
      server = nixpkgs.lib.nixosSystem {
        inherit system;
        modules =
          [
            sops-nix.nixosModules.sops
            ./host/confiuration.nix
            ./host/hardware-confiuration.nix
            ./host/hostModules/secrets.nix
          ]
          ++ serviceModules;

        specialArgs = {inherit inputs user sshKeys pkgs sops-nix;};
      };
    };
  };
}
