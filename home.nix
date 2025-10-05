{ config, pkgs, ... }:

{
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "25.11";  # Match system.stateVersion to avoid potential warnings

  programs.fish.enable = true;
  programs.bash.enable = true;

  programs.git = {
    enable = true;
    userName = "";
    userEmail = "shorkicalypso@gmail.com";
  };

  programs.neovim.enable = true;
  programs.firefox.enable = true;

  # Python via home.packages (standard HM way—adds to PATH)
  home.packages = with pkgs; [
    python311  # Or python312 if preferred
  ];

  home.sessionVariables = {
    EDITOR = "nano";
    LANG = "en_US.UTF-8";
  };

  # Nixcord config (requires nixcord input passed via flake)
  programs.nixcord = {
    enable = true;  # Installs Discord + Vencord
    vesktop.enable = true;  # Optional: Electron-based Discord fork
    # dorion.enable = true;  # Optional: If you want Dorion (needs initial manual login)

    config = {
      useQuickCss = true;
      themeLinks = [
        # "https://raw.githubusercontent.com/some-user/some-theme/main/theme.css"  # Example theme
      ];
      #frameless = true;  # Borderless window
    };

    # Use extraConfig for unlisted plugins (hideAttachments and ignoreActivities not built-in)
    extraConfig = {
      hideAttachments = {
        enable = true;
      };
      ignoreActivities = {
        #enable = true;
        #ignorePlaying = true;
        #ignoredActivities = [ "Spotify" ];
      };
      # Add more unlisted plugins here as needed
    };
  };
}
