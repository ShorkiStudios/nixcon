{ config, pkgs, nixcord, ... }:

{
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "25.05";  # Matches system.stateVersion

  programs.fish.enable = true;
  programs.bash.enable = true;

  programs.git = {
    enable = true;
    userName = "";
    userEmail = "shorkicalypso@gmail.com";
  };

  programs.neovim.enable = true;
  programs.firefox.enable = true;

  home.packages = with pkgs; [
    python311  # Python 3.11 (stable in 25.05)
  ];

  home.sessionVariables = {
    EDITOR = "nano";
    LANG = "en_US.UTF-8";
  };

  programs.nixcord = {
    enable = true;
    vesktop.enable = true;
    # dorion.enable = true;  # Uncomment if you want to try Dorion

    config = {
      useQuickCss = true;
      themeLinks = [
        # "https://raw.githubusercontent.com/some-user/some-theme/main/theme.css"
      ];
      # frameless = true;
    };

    # Commenting out extraConfig to avoid potential unsupported plugin errors
    /*
    extraConfig = {
      hideAttachments = {
        enable = true;
      };
      ignoreActivities = {
        # enable = true;
        # ignorePlaying = true;
        # ignoredActivities = [ "Spotify" ];
      };
    };
    */
  };
}
