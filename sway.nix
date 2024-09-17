{ pkgs, lib, ... }:

let
  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts  
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };

in
{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty"; 
      startup = [
        #{ command = "firefox"; }
      ];
    };
  };

  home.packages = with pkgs; [
    grim
    slurp
    sway
    swaybg
    swaylock
    swayidle
    dbus-sway-environment
    wayland
    configure-gtk
    wl-clipboard
    xdg-utils # for openning default programms when clicking links
    glib # gsettings
    bemenu # wayland clone of dmenu
    mako # notification daemon
    pamixer
    playerctl
    #FIXME: fcitx5 seems not working with alacritty, relegated to using XWayland
    #(writeShellScriptBin "alacritty" ''WINIT_UNIX_BACKEND=x11 ${pkgs.alacritty}/bin/alacritty "$@"'')
  ];

  # warning: xdg-desktop-portal 1.17 reworked how portal implementations are loaded
  # https://github.com/flatpak/xdg-desktop-portal/blob/1.18.1/doc/portals.conf.rst.in
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };

  # screenshots
  # bindsym $mod+c exec grim  -g "$(slurp)" /tmp/$(date +'%H:%M:%S.png')
  # systemd.user.services.swayidle = {
  #   description = "Idle Manager for Wayland";
  #   documentation = [ "man:swayidle(1)" ];
  #   wantedBy = [ "sway-session.target" ];
  #   partOf = [ "graphical-session.target" ];
  #   path = [ pkgs.bash ];
  #   serviceConfig = {
  #     ExecStart = ''
  #         ${pkgs.swayidle}/bin/swayidle -w -d \
  #                   timeout 300 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
  #                   resume '${pkgs.sway}/bin/swaymsg "output * dpms on"'
  #       '';
  #   };
  # };
}
