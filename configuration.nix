{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Vulkan/OpenGL support (for gaming, Steam, etc.)
  hardware.graphics = {
    enable = true;  # Replaces deprecated hardware.opengl.enable
    enable32Bit = true;  # Replaces deprecated hardware.opengl.driSupport32Bit; critical for 32-bit Wine/Proton support
    extraPackages = with pkgs; [
      vaapiIntel
      intel-media-driver  # VA-API/Vulkan Video for Intel Iris Xe
    ];
  };

  networking.hostName = "ShorkSpace";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Mullvad VPN
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;  # Ensures CLI/GUI matches daemon version
  };

  # Full Bluetooth profiles including AVRCP
  services.blueman.enable = true;  # Optional: Bluetooth manager for easier pairing (adds tray icon)
  environment.etc."bluetooth/main.conf".text = lib.mkForce ''
    [General]
    ControllerMode = bredrle
    Experimental = true
    Privacy = device

    [Policy]
    AutoEnable = true

    [GATT]
    GATTEnable = true

    [LE]
    GATTEnableLE = true

    [Service]
    AutoEnable = true
    Enable = Source,Sink,Control,Media,Socket  # Enables AVRCP (Media/Control) alongside A2DP (Source/Sink)
  '';

  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  security.sudo.extraRules = [{
    users = ["user"];
    commands = [{
      command = "ALL";
      options = ["NOPASSWD"];
    }];
  }];

  programs.fish.enable = true;
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    fish gh git lazygit element-desktop wget ghostty vscodium neovim tree
    qemu kdePackages.yakuake ani-cli btop yt-dlp localsend unzip vencord bat
    mullvad-vpn
    libnotify  # For notifications
    bluez  # For bluetoothctl
    kdePackages.kdialog  # Qt6 version to override deprecated Qt5 alias
    # Gaming setup with Lutris overrides for better compatibility
    (lutris.override {
      extraPkgs = pkgs: with pkgs; [
        wineWowPackages.stable  # Wine for Windows games (use .wayland if switching to Wayland)
        vulkan-loader
        dxvk  # DirectX to Vulkan translation
        gamescope  # Borderless fullscreen and scaling
      ];
      extraLibraries = pkgs: with pkgs; [
        attr  # Provides libattr.so; fixes mktemp/libattr errors
        jansson
        samba  # Network/auth fixes
        zlib
        libpng
        freetype
        fontconfig
      ];
    })
    protonup-qt  # For managing Proton-GE versions
  ];

  # Steam integration (removes the plain 'steam' from packages; this handles it better)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;  # For remote play if needed
    dedicatedServer.openFirewall = true;  # For hosting servers
  };

  # Gamemode for performance boosts during gaming
  programs.gamemode.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.openssh.enable = true;
  system.stateVersion = "25.11";
}
