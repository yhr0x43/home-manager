{ config, pkgs, ... }:

{
  imports = [
    ./emacs.nix
    ./dunst.nix
    ./rime.nix
    ./sway.nix
    ./zsh.nix
  ];

  home.username = "yhrc";
  home.homeDirectory = "/home/yhrc";

  home.stateVersion = "24.11";

  xdg.enable = true;

  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;

  xdg.userDirs = {
    enable = true;
    desktop = "${config.home.homeDirectory}";
    documents = "${config.home.homeDirectory}/dox";
    download = "${config.home.homeDirectory}/dl";
    music = "${config.home.homeDirectory}/mus";
    pictures = "${config.home.homeDirectory}/pic";
    publicShare = "${config.home.homeDirectory}/pub";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/vid";
  };

  programs.password-store = {
    enable = true;
    package = with pkgs; symlinkJoin {
      name = "pass-with-env";
      paths = [ (writeShellScriptBin "pass" ''
          ${pkgs.coreutils}/bin/env PASSWORD_STORE_DIR=${config.xdg.dataHome}/password-store ${pkgs.pass}/bin/pass "$@"
        '') ];
      postBuild = "ln -s ${pkgs.pass}/bin/passmenu $out";
    };
    # NOTE this does not work when shell is not managed by home-manager
    #settings.PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
  };

  programs.alacritty.enable = true;
  
  programs.zathura.enable = true;

  programs.git = {
    enable = true;
    ignores = [ "*~" "*.swp" ];
    package = pkgs.gitFull;
    userEmail = "yhr0x43@gmail.com";
    userName = "yhr0x43";
  };

  home.packages = with pkgs; [
    # Browsers
    firefox
    filezilla

    # Editors
    jetbrains.idea-community


    # Misc. Unix-ish tools
    fzf
    lm_sensors
    ncdu
    nixfmt-rfc-style
    silver-searcher
    zeal
    
    localsend

    # Media
    xournalpp
    simple-scan
    texlive.combined.scheme-full
    mpv
    feh

    # Office
    libreoffice-fresh

    # python38Packages.xdot

    maestral

    (aspellWithDicts (d: [ d.en d.en-computers ]))
    ispell
  ];

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
