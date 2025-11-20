# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./private/hardware-configuration.nix ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    device = config.iconfig.bootDevice;
  };

  networking.hostName = "nixos";
  networking.enableIPv6 = true;
  networking.interfaces.${config.iconfig.iface} = {
    ipv4.addresses = [
      {
        address = config.iconfig.v4Address;
        prefixLength = config.iconfig.v4PrefixLength;
      }
    ];
    ipv6.addresses = [
      {
        address = config.iconfig.v6Address;
        prefixLength = config.iconfig.v6PrefixLength;
      }
    ];
  };
  networking.defaultGateway = config.iconfig.v4Gateway;
  networking.defaultGateway6 = {
    address = config.iconfig.v6Gateway;
    interface = config.iconfig.iface;
  };
  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
  ];
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  time.timeZone = "Etc/UTC";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${config.iconfig.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      config.iconfig.pubSshKey
    ];
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  environment.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake 'git+ssh://git@github.com/${config.iconfig.githubUser}/FamilyDirectoryCardDAV?submodules=1#nixos'";
  };

  programs.ssh = {
    extraConfig = "
      Host github.com
        IdentityFile /home/${config.iconfig.username}/id_carddav_deploy
        IdentitiesOnly yes
    ";
  };

  services.openssh = {
    enable = true;
    ports = [ config.iconfig.sshPort ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ config.iconfig.username ];
    };
  };

  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
