{pkgs, ...}: let
  cfgFile = pkgs.writeText "logid.cfg" ''
    devices: ({
      name: "MX Master 3S";

      // A lower threshold number makes the wheel switch to free-spin mode
      // quicker when scrolling fast.
      smartshift: { on: true; threshold: 15; };

      hiresscroll: { hires: false; invert: false; target: false; };

      // Higher numbers make the mouse more sensitive (cursor moves faster),
      // 4000 max for MX Master 3.
      dpi: 1500;

      buttons: (

        // Make thumb button 10.
        { cid: 0x56; action = { type: "Keypress"; keys: ["KEY_FORWARD"]; }; },

        // Make top button 11.
        { cid: 0x53; action = { type: "Keypress"; keys: ["KEY_BACK"];    }; },

      	// Make gesture button work as Super
      	{ cid: 0xc3, action = { type: "Keypress"; keys: ["KEY_LEFTMETA"]; }; }
      );
    });
  '';
in {
  systemd.packages = [pkgs.logiops];
  services.dbus.packages = [pkgs.logiops];
  systemd.services.logid = {
    wantedBy = ["default.target"];
    restartTriggers = [cfgFile];
  };

  environment.etc."logid.cfg".source = cfgFile;
}
