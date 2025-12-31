{lib, ...}: {
  boot.kernel.sysctl = lib.mkDefault {
    "vm.overcommit_memory" = "1";
  };
}
