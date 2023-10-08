{...}: let
  usernamePath = "/var/lib/spotifyd/username";
  passwordPath = "/var/lib/spotifyd/password";
in {
  sops.secrets."spotifyd/password" = {
    path = passwordPath;
    owner = "spotifyd";
  };
  sops.secrets."spotifyd/username" = {
    path = usernamePath;
    owner = "spotifyd";
  };
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        audio_format = "S16";
        autoplay = true;
        username = "cat ${usernamePath}";
        password_cmd = "cat ${passwordPath}";
        backend = "pulseaudio";
        bitrate = 320;
        cache_path = "cache_directory";
        dbus_type = "session";
        device = "default";
        device_name = "patchouli";
        device_type = "computer";
        initial_volume = "90";
        max_cache_size = 1000000000;
        mixer = "PCM";
        no_audio_cache = true;
        normalisation_pregain = -10;
        on_song_change_hook = "command_to_run_on_playback_events";
        # proxy = "http://proxy.example.org:8080";
        use_keyring = true;
        use_mpris = true;
        volume_controller = "alsa";
        volume_normalisation = true;
        # zeroconf_port = 1234;
      };
    };
  };
}
