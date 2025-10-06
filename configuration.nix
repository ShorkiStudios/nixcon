{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

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
  };

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
    QT_QPA_PLATFORM = "xcb";
    ANDROID_SDK_ROOT = "${pkgs.android-studio}/share/android-sdk";
    LIBVA_DRIVER_NAME = "iHD";  # Prioritize intel-media-driver for Iris Xe
    MESA_LOADER_DRIVER_OVERRIDE = "iris";  # Force Iris driver
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json";  # Force Intel Vulkan
    MESA_NO_LVP = "1";  # Disable llvmpipe
  };

  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "dialout" "adbusers" "kvm" ];
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

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    fish gh git lazygit element-desktop wget ghostty vscodium neovim tree
    qemu kdePackages.yakuake ani-cli btop yt-dlp localsend unzip vencord bat
    mullvad-vpn fastfetch qemu libvirt virt-manager bridge-utils OVMF
    libnotify virt-viewer qemu-utils ungoogled-chromium
    bluez gparted qbittorrent gnome-disk-utility appimage-run home-manager
    kdePackages.kdialog
    picocom
    esptool
    android-studio
    intel-gpu-tools
    steam-run
    libva-utils
    mesa-demos
    vulkan-tools
    (lutris.override {
      extraPkgs = pkgs: with pkgs; [
        wineWowPackages.stable
        vulkan-loader
        dxvk
        gamescope
      ];
      extraLibraries = pkgs: with pkgs; [
        attr
        jansson
        samba
        zlib
        libpng
        freetype
        fontconfig
      ];
    })
    protonup-qt
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.openssh.enable = true;
  system.stateVersion = "25.05";  # Updated to match stable release
}
