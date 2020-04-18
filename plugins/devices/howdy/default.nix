{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.icebox.static.devices.howdy;

  # `dark_threshold` is required for X1 Carbon 7th to work
  configINI = pkgs.runCommand "config.ini" { } ''
    cat ${cfg.package}/lib/security/howdy/config.ini > $out
    substituteInPlace $out --replace 'device_path = none' 'device_path = ${cfg.device}'
    substituteInPlace $out --replace 'dark_threshold = 50' 'dark_threshold = ${
      toString cfg.dark-threshold
    }'
    substituteInPlace $out --replace 'certainty = 3.5' 'certainty = ${
      toString cfg.certainty
    }'
  '';
  pam-rule = pkgs.lib.mkDefault (pkgs.lib.mkBefore
    "auth sufficient ${pkgs.pam_python}/lib/security/pam_python.so ${cfg.package}/lib/security/howdy/pam.py");
in {
  options = {
    icebox.static.devices.howdy = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable howdy and PAM module for face recognition.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.howdy;
        defaultText = "pkgs.howdy";
        description = ''
          Howdy package to use.
        '';
      };

      device = mkOption {
        type = types.path;
        default = "/dev/video0";
        description = ''
          Device file connected to the IR sensor.
        '';
      };

      certainty = mkOption {
        type = types.int;
        default = 3.5;
        description = ''
          The certainty of the detected face belonging to the user of the account. On a scale from 1 to 10, values above 5 are not recommended.
        '';
      };

      dark-threshold = mkOption {
        type = types.int;
        default = 50;
        description = ''
          Because of flashing IR emitters, some frames can be completely unlit. Skip the frame if the lowest 1/8 of the histogram is above this percentage of the total. The lower this setting is, the more dark frames are ignored.
        '';
      };

      pamServices = mkOption {
        type = with types; listOf str;
        default = [ ];
        description =
          "Names of security.pam.services.<name> to enable Howdy as the first authentication method.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    environment.etc."howdy/config.ini".source = configINI;
    security.pam.services = builtins.listToAttrs
      (map (n: attrsets.nameValuePair (n) ({ text = pam-rule; }))
        cfg.pamServices);
    icebox.overlays = [
      (self: super: {
        howdy = (super.callPackage ./packages/howdy.nix { });
        pam_python = (super.callPackage ./packages/pam_python.nix { });
      })
    ];
  };
}
