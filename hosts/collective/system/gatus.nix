{...}: {
  vanutp.gatus = {
    enable = true;
    domain = "status.vanutp.dev";
    checks = {
      maven = {
        url = "https://maven.vanutp.dev/api/maven/details";
        conditions = [
          "[STATUS] == 200"
          "[BODY].files[0].name == main"
        ];
      };
      mctgauth = {
        url = "https://mc-auth.vanutp.dev";
        conditions = ["[STATUS] == 200"];
      };
      vaultwarden = {
        url = "https://pwd.vanutp.dev/api/alive";
        conditions = ["[STATUS] == 200"];
      };
      freshrss = {
        url = "https://rss.vanutp.dev/api/fever.php";
        conditions = ["[STATUS] == 200"];
      };
      wakapi = {
        url = "https://waka.vanutp.dev/api/health";
        conditions = [
          "[STATUS] == 200"
          "[BODY] == app=1\ndb=1"
        ];
      };
      umami = {
        url = "https://zond.vanutp.dev/api/heartbeat";
        conditions = [
          "[STATUS] == 200"
          "[BODY].ok == true"
        ];
      };
    };
  };
}
