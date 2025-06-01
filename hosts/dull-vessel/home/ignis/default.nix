{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    (inputs.ignis.packages.${pkgs.system}.ignis.override {
      extraPackages = with pkgs.python312Packages; [
        materialyoucolor
        jinja2
        pillow
      ];
    })
  ];
}
