{
  config,
  lib,
  pkgs,
  ...
}:

let
  carddavProxy = pkgs.stdenv.mkDerivation {
    pname = "proxy";
    version = config.iconfig.proxyVersion;

    src = pkgs.fetchurl {
      url = config.iconfig.proxyUrl;
      sha256 = config.iconfig.proxySha256;
    };

    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      install -m755 $src $out/bin/proxy
    '';
  };
in
{
  security.acme = {
    acceptTerms = true;
    defaults.email = config.iconfig.acmeEmail;
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    virtualHosts = lib.mapAttrs (host: vhostCfg: {
      enableACME = true;
      forceSSL = true;
      locations."= /.well-known/carddav" = {
        return = "301 /";
      };
      locations."= /apple" = {
        alias = config.ios.profiles.${host};
        extraConfig = ''
          default_type application/x-apple-aspen-config;
          add_header Content-Disposition 'attachment; filename="${vhostCfg.iosDotMobileConfigName}.mobileconfig"';
        '';
      };
      locations."/" = {
        proxyPass = "http://unix:/run/carddav/proxy.sock:";
        extraConfig = ''
          proxy_request_buffering off;
          proxy_set_header X-Api-Endpoint ${vhostCfg.apiEndpoint};
        '';
      };
    }) config.iconfig.virtualHosts;
  };

  systemd.services.carddav-proxy = {
    description = "Go CardDAV proxy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${carddavProxy}/bin/proxy";
      User = "nginx";
      Group = "nginx";
      RuntimeDirectory = "carddav";
      RuntimeDirectoryMode = "0750";
    };
  };
}
