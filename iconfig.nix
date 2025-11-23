{ lib, ... }:

let
  inherit (lib) mkOption types;
in
{
  options.iconfig = {
    bootDevice = mkOption { type = types.str; };
    iface = mkOption { type = types.str; };
    v4Address = mkOption { type = types.str; };
    v4PrefixLength = mkOption { type = types.int; };
    v6Address = mkOption { type = types.str; };
    v6PrefixLength = mkOption { type = types.int; };
    v4Gateway = mkOption { type = types.str; };
    v6Gateway = mkOption { type = types.str; };
    username = mkOption { type = types.str; };
    pubSshKey = mkOption { type = types.str; };
    sshPort = mkOption { type = types.int; };
    githubUser = mkOption { type = types.str; };
    acmeEmail = mkOption { type = types.str; };
    virtualHosts = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              apiEndpoint = mkOption { type = types.str; };
              iosDavDescription = mkOption { type = types.str; };
              iosDotMobileConfigName = mkOption { type = types.str; };
              iosProfileDisplayName = mkOption { type = types.str; };
              iosDavUUID = mkOption { type = types.str; };
              iosDavPkg = mkOption { type = types.str; };
              iosProfileUUID = mkOption { type = types.str; };
              iosProfilePkg = mkOption { type = types.str; };
            };
          }
        )
      );
    };
    proxyUrl = mkOption { type = types.str; };
    proxySha256 = mkOption { type = types.str; };
    proxyVersion = mkOption { type = types.str; };
  };
}
