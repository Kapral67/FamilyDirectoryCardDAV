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
  };
}
