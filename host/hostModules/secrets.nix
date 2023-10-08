{
  sops-nix,
  user,
  ...
}: {
  sops.defaultSopsFile = ../../secrets/services.yaml;
  sops.age.sshKeyPaths = ["/home/${user}/.ssh/ed25519"];
}
