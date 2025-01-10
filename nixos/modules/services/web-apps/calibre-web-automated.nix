{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.calibre-web-automated;

  inherit (lib)
    concatStringsSep
    mkEnableOption
    mkIf
    mkOption
    optional
    optionalString
    types
    ;
in
{
  options = {
    services.calibre-web-automated = {
      enable = mkEnableOption "Calibre-Web-Automated";

      package = lib.mkPackageOption pkgs "calibre-web-automated" { };

      listen = {
        ip = mkOption {
          type = types.str;
          default = "::1";
          description = ''
            IP address that Calibre-Web should listen on.
          '';
        };

        port = mkOption {
          type = types.port;
          default = 8083;
          description = ''
            Listen port for Calibre-Web.
          '';
        };
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/calibre-web-automated";
        description = ''
          The directory where CWA stores its data.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "calibre-web-automated";
        description = "User account under which Calibre-Web runs.";
      };

      group = mkOption {
        type = types.str;
        default = "calibre-web-automated";
        description = "Group account under which Calibre-Web runs.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open ports in the firewall for the server.
        '';
      };

      options = {
        calibreLibrary = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = ''
            Path to Calibre library.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.calibre-web-automated =
      let
        appDb = "${cfg.dataDir}/app.db";
        calibreWebCmd = "${cfg.package}/bin/calibre-web-automated -p ${appDb}";

        settings = concatStringsSep ", " (
          [
            "config_port = ${toString cfg.listen.port}"
          ]
          ++ optional (
            cfg.options.calibreLibrary != null
          ) "config_calibre_dir = '${cfg.options.calibreLibrary}'"
        );
      in
      {
        description = "Web app for browsing, reading and downloading eBooks stored in a Calibre database";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;

          StateDirectory = cfg.dataDir;

          ExecStartPre = pkgs.writeShellScript "calibre-web-pre-start" (''
            __RUN_MIGRATIONS_AND_EXIT=1 ${calibreWebCmd}

            ${pkgs.sqlite}/bin/sqlite3 ${appDb} "update settings set ${settings}"
          '');

          ExecStart = "${calibreWebCmd} -i ${cfg.listen.ip}";
          Restart = "on-failure";
        };
      };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listen.port ];
    };

    users.users = mkIf (cfg.user == "calibre-web-automated") {
      calibre-web-automated = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = mkIf (cfg.group == "calibre-web-automated") {
      calibre-web-automated = { };
    };
  };

  meta.maintainers = with lib.maintainers; [ ];
}
