{ config, pkgs, lib, ... }:

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
      systemctl --user stop pipewire xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire xdg-desktop-portal xdg-desktop-portal-wlr
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
      bars = [
        { command = "${pkgs.waybar}/bin/waybar"; }
      ];
      floating.criteria = [
        { class = "wechat"; }
        { window_type = "dialog"; }
        { window_role = "dialog"; }
      ];
      window.commands = [
        {
          command = "title_format \"[XWayland] %title\"";
          criteria = { shell = "xwayland"; };
        }
      ];
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "bemenu-run";
      output.eDP-1.scale = "1.5";
      keybindings = let cfg = config.wayland.windowManager.sway.config; in {
          "${cfg.modifier}+Return" = "exec ${cfg.terminal}";
          "${cfg.modifier}+Shift+q" = "kill";
          "${cfg.modifier}+d" = "exec ${cfg.menu}";

          "${cfg.modifier}+${cfg.left}"  = "focus left";
          "${cfg.modifier}+${cfg.down}"  = "focus down";
          "${cfg.modifier}+${cfg.up}"    = "focus up";
          "${cfg.modifier}+${cfg.right}" = "focus right";

          "${cfg.modifier}+Left"  = "focus left";
          "${cfg.modifier}+Down"  = "focus down";
          "${cfg.modifier}+Up"    = "focus up";
          "${cfg.modifier}+Right" = "focus right";

          "${cfg.modifier}+Shift+${cfg.left}"  = "move left";
          "${cfg.modifier}+Shift+${cfg.down}"  = "move down";
          "${cfg.modifier}+Shift+${cfg.up}"    = "move up";
          "${cfg.modifier}+Shift+${cfg.right}" = "move right";

          "${cfg.modifier}+Shift+Left"  = "move left";
          "${cfg.modifier}+Shift+Down"  = "move down";
          "${cfg.modifier}+Shift+Up"    = "move up";
          "${cfg.modifier}+Shift+Right" = "move right";

          "${cfg.modifier}+b" = "splith";
          "${cfg.modifier}+v" = "splitv";
          "${cfg.modifier}+a" = "focus parent";
          "${cfg.modifier}+f" = "fullscreen toggle";
          "${cfg.modifier}+t" = "floating toggle";

          "${cfg.modifier}+s" = "layout stacking";
          "${cfg.modifier}+w" = "layout tabbed";
          "${cfg.modifier}+e" = "layout toggle split";

          "${cfg.modifier}+1" = "workspace number 1";
          "${cfg.modifier}+2" = "workspace number 2";
          "${cfg.modifier}+3" = "workspace number 3";
          "${cfg.modifier}+4" = "workspace number 4";
          "${cfg.modifier}+5" = "workspace number 5";
          "${cfg.modifier}+6" = "workspace number 6";
          "${cfg.modifier}+7" = "workspace number 7";
          "${cfg.modifier}+8" = "workspace number 8";
          "${cfg.modifier}+9" = "workspace number 9";
          "${cfg.modifier}+0" = "workspace number 10";

          "${cfg.modifier}+Shift+1" = "move container to workspace number 1";
          "${cfg.modifier}+Shift+2" = "move container to workspace number 2";
          "${cfg.modifier}+Shift+3" = "move container to workspace number 3";
          "${cfg.modifier}+Shift+4" = "move container to workspace number 4";
          "${cfg.modifier}+Shift+5" = "move container to workspace number 5";
          "${cfg.modifier}+Shift+6" = "move container to workspace number 6";
          "${cfg.modifier}+Shift+7" = "move container to workspace number 7";
          "${cfg.modifier}+Shift+8" = "move container to workspace number 8";
          "${cfg.modifier}+Shift+9" = "move container to workspace number 9";
          "${cfg.modifier}+Shift+0" = "move container to workspace number 10";

          "${cfg.modifier}+Shift+minus" = "move scratchpad";
          "${cfg.modifier}+minus"       = "scratchpad show";

          "${cfg.modifier}+Shift+c" = "reload";
          "${cfg.modifier}+Shift+e" =
            "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

          "${cfg.modifier}+r" = "mode resize";
          
          "XF86AudioRaiseVolume" = "exec pamixer -i 5";
          "XF86AudioLowerVolume" = "exec pamixer -d 5";
          "XF86AudioMute" = "exec pamixer -m";

          "XF86MonBrightnessUp"   = "exec light -A 5";
          "XF86MonBrightnessDown" = "exec light -U 5";

          "Print" = "exec grim  -g \"$(slurp)\" /tmp/$(date +'%H:%M:%S.png')";
        };
      startup = [
        { command = "fcitx5"; }
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
    glib      # gsettings
    bemenu    # wayland clone of dmenu
    wev
    pamixer
    playerctl
    xfce.thunar
  ];  

  # warning: xdg-desktop-portal 1.17 reworked how portal implementations are loaded
  # https://github.com/flatpak/xdg-desktop-portal/blob/1.18.1/doc/portals.conf.rst.in
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
    config = {
      common.default = "*";
      sway.default = lib.mkDefault [ "wlr" "gtk" ];
    };
  };

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
