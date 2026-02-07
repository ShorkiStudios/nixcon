{ config, lib, pkgs, zen-browser, ... }:  # Added zen-browser to arguments

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;  # Stable kernel in 25.05
  boot.kernelModules = [ "kvm-intel" "cdc_acm" "usbserial" ];
  boot.kernelParams = [ "console=ttyS0,115200n8" "i915.enable_psr=0" "i915.fastboot=1" ];

  hardware.bluetooth.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiIntel
      intel-media-driver
      vulkan-loader
      mesa  # Stable Mesa in 25.05, uses iris for Iris Xe
      intel-compute-runtime
      vpl-gpu-rt
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiIntel
      intel-media-driver
      vulkan-loader
      mesa
    ];
  };

  networking.hostName = "nullspace";
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf.enable = true;
    };
    onBoot = "start";  # Start VMs on boot
    onShutdown = "suspend";  # Suspend VMs on shutdown
  };

  # Set default libvirt URI and socket permissions
  environment.etc."libvirt/libvirtd.conf".text = ''
    unix_sock_group = "libvirtd"
    unix_sock_rw_perms = "0770"
    uri_default = "qemu:///system"
  '';

  networking.networkmanager.enable = true;

  # Enable MAC address randomization for Wi-Fi connections
  environment.etc."NetworkManager/conf.d/10-randomize-mac.conf".text = ''
    [device]
    wifi.scan-rand-mac-address=yes
    [connection]
    wifi.cloned-mac-address=random
  '';

  # Open SPICE ports for virt-manager graphical consoles
  networking.firewall.allowedTCPPorts = [ 5900 5901 ];

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
  services.displayManager.sddm.wayland.enable = true;  # Enable Wayland for SDDM
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

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  services.blueman.enable = true;
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
    Enable = Source,Sink,Control,Media,Socket
  '';

  systemd.services."serial-getty@ttyS0" = {
    enable = true;
    wantedBy = [ "getty.target" ];
    serviceConfig = {
      Restart = "always";
    };
  };

  programs.adb.enable = true;
  nixpkgs.config.android_sdk.accept_license = true;

  environment.variables = {
    ANDROID_SDK_ROOT = "${pkgs.android-studio}/share/android-sdk";
    LIBVA_DRIVER_NAME = "iHD";  # Prioritize intel-media-driver for Iris Xe
    MESA_LOADER_DRIVER_OVERRIDE = "iris";  # Force Iris driver
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json";  # Force Intel Vulkan
    MESA_NO_LVP = "1";  # Disable llvmpipe
  };

  environment.pathsToLink = [ "/share/applications" "/share" ];  # Ensure desktop entries are linked

  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "dialout" "adbusers" "kvm" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  security.sudo.extraRules = [{
    users = ["user"];
    commands = [{
      command = "ALL";
      options = ["NOPASSWD"];
    }];
  }];

  programs.niri.enable = true;
  programs.hyprland = {
  enable = true;
  xwayland.enable =true;
  };
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  environment.systemPackages = with pkgs; [
    fish gh git lazygit element-desktop wget ghostty vscodium neovim tree
    qemu kdePackages.yakuake ani-cli btop yt-dlp localsend unzip vencord bat
    mullvad-vpn fastfetch libvirt virt-manager bridge-utils OVMF
    libnotify virt-viewer qemu-utils ungoogled-chromium
    bluez gparted qbittorrent gnome-disk-utility appimage-run home-manager blender
    kdePackages.kdialog mpv zoom-us wine libreoffice-qt6-fresh
    picocom esptool android-studio intel-gpu-tools steam-run
    libva-utils mesa-demos vulkan-tools
    kdePackages.xdg-desktop-portal-kde pkgs.waybar pkgs.dunst libnotify swww alacritty kitty rofi-wayland pkgs.networkmanagerapplet pkgs.grim pkgs.wl-clipboard
    spice spice-gtk   libguestfs pkgs.rar
    (lutris.override {
      extraPkgs = pkgs: with pkgs; [
        wineWowPackages.stable
        vulkan-loader
        dxvk
        gamescope
      ];
      extraLibraries = pkgs: with pkgs; [
        attr jansson samba zlib libpng freetype fontconfig
      ];
    })
    protonup-qt
    zen-browser.packages.${pkgs.system}.default  # Zen Browser (stable Twilight release)
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.openssh.enable = true;
  system.stateVersion = "25.05";
}
