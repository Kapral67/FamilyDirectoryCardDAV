{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types mapAttrs;

  mkProfile =
    host: vhostCfg:
    pkgs.writeText "${vhostCfg.iosDotMobileConfigName}.mobileconfig" ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>PayloadContent</key>
        <array>
          <dict>
            <key>CardDAVAccountDescription</key>
            <string>${vhostCfg.iosDavDescription}</string>
            <key>CardDAVHostName</key>
            <string>${host}</string>
            <key>CardDAVPort</key>
            <integer>443</integer>
            <key>CardDAVUseSSL</key>
            <true/>
            <key>PayloadIdentifier</key>
            <string>${vhostCfg.iosDavPkg}</string>
            <key>PayloadType</key>
            <string>com.apple.carddav.account</string>
            <key>PayloadUUID</key>
            <string>${vhostCfg.iosDavUUID}</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
          </dict>
        </array>
        <key>PayloadDisplayName</key>
        <string>${vhostCfg.iosProfileDisplayName}</string>
        <key>PayloadIdentifier</key>
        <string>${vhostCfg.iosProfilePkg}</string>
        <key>PayloadType</key>
        <string>Configuration</string>
        <key>PayloadUUID</key>
        <string>${vhostCfg.iosProfileUUID}</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
      </dict>
      </plist>
    '';
in
{
  options.ios.profiles = mkOption {
    type = types.attrsOf types.path;
    readOnly = true;
  };
  config.ios.profiles = mapAttrs mkProfile config.iconfig.virtualHosts;
}
