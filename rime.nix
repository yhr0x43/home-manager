{ config, pkgs, ... }:

{
  xdg.dataFile."fcitx5/rime" = {
    recursive = true;
    source = ./rime;
    onChange = "${pkgs.fcitx5}/bin/fcitx5-remote -r";
  };
}
