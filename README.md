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
    virtualHosts = {
      "dav.example.com" = {
        apiEndpoint = "api.example.com/carddav";
        iosDavDescription = "Example Family Directory";
        iosDotMobileConfigName = "exampleFamilyDirectory";
        iosProfileDisplayName = "Example CardDAV";
        iosDavUUID = "cac2088e-b474-4f60-937a-bfffb6d29f79";
        iosDavPkg = "com.example.carddav";
        iosProfileUUID = "ffe1511e-313b-4087-9de4-af09fe05ba25";
        iosProfilePkg = "com.example.mobileconfig";
      };
    };
    proxyUrl = "https://static.example.com/proxy.exe";
    proxySha256 = "sha256-AAA/FFF/EEE=";
    proxyVersion = "0.1.0";
  };
}
```
