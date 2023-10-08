{sops-nix, ...}: {
  imports = [sops-nix.nixosModules.sops];
  sops.defaultSopsFile = ../../secrets/services.yaml;
  sops.secrets."spotifyd/username" = {};
}
