# FamilyDirectoryCardDAV

### Example `./private/config.nix`

```nix
{ config, ... }:

{
  iconfig = {
    bootDevice = "/dev/sda";
    iface = "eth0";
    v4Address = "<ipv4>";
    v4PrefixLength = 24;
    v6Address = "<ipv6>";
    v6PrefixLength = 56;
    v4Gateway = "<ipv4>";
    v6Gateway = "<ipv6>";
    username = "user";
    pubSshKey = "ssh-rsa AAAFFF user";
    sshPort = 22;
    githubUser = "User";
    acmeEmail = "acme@example.com";
    virtualHosts = [ "dav.example.com" ];
  };
}
```
