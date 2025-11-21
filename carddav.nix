{
  config,
  lib,
  pkgs,
  ...
}:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = config.iconfig.acmeEmail;
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    virtualHosts = lib.genAttrs config.iconfig.virtualHosts (host: {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        return = "200 '<html><body>It works</body></html>'";
        extraConfig = ''
          default_type text/html;
        '';
      };
    });
  };
}
