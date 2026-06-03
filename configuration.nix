{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # ── Boot ────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams   = [
    "acpi_backlight=native"
    "amd_pstate=active"
  ];

  # ── Network ─────────────────────────────────────────────────────
  networking.hostName            = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

boot.extraModprobeConfig = ''
  options rtw89pci disable_aspm_l1=y
  options rtw89pci disable_aspm_l1ss=y
'';

  # ── Time & Locale ───────────────────────────────────────────────
  time.timeZone      = "Asia/Baku";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "az_AZ";
    LC_IDENTIFICATION = "az_AZ";
    LC_MEASUREMENT    = "az_AZ";
    LC_MONETARY       = "az_AZ";
    LC_NAME           = "az_AZ";
    LC_NUMERIC        = "az_AZ";
    LC_PAPER          = "az_AZ";
    LC_TELEPHONE      = "az_AZ";
    LC_TIME           = "az_AZ";
  };

  # ── Desktop ─────────────────────────────────────────────────────
  services.xserver.enable     = true;
  services.xserver.xkb.layout = "us";
  services.displayManager.sddm.enable       = true;
  services.desktopManager.plasma6.enable    = true;

  # ── Graphics ────────────────────────────────────────────────────
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable    = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable     = true;
    powerManagement.enable = true;
    open           = false;
    nvidiaSettings = true;
    prime = {
      offload.enable          = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ── CPU & Power ──────────────────────────────────────────────────
  powerManagement.cpuFreqGovernor = "performance";
  systemd.services.cpu-max-freq = {
    description        = "Limit CPU to 4.0 GHz";
    wantedBy           = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
        echo 4000000 > "$cpu/scaling_max_freq" || true
      done
    '';
  };

  # ── Memory ───────────────────────────────────────────────────────
  zramSwap = {
    enable        = true;
    memoryPercent = 50;
  };

  # ── Audio ────────────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  # ── Printing ─────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── Storage ──────────────────────────────────────────────────────
  fileSystems."/mnt/ssd" = {
    device  = "/dev/disk/by-uuid/REDACTED";
    fsType  = "ext4";
    options = [ "noatime" ];
  };

  # ── User ─────────────────────────────────────────────────────────
  users.users.rage = {
    isNormalUser = true;
    description  = "RAGE";
    extraGroups  = [
      "networkmanager"
      "wheel"
      "wireshark"
    ];
  };

  # ── Programs ─────────────────────────────────────────────────────
  programs.firefox.enable   = true;
  programs.steam.enable     = true;
  programs.wireshark.enable = true;

  # ── Packages ─────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    
  git wget
  curl
  pciutils
  fastfetch   
  ghostty
  octaveFull
  python3
  jupyter
  gnuradio
  kicad
  freecad
  git
  geekbench
  tmux
  nmap
  gamemode
  mangohud
  tcpdump
  iperf3
  obs-studio
  spotify
  discord
  onlyoffice-desktopeditors
  wireshark
  protonplus
  openrgb-with-all-plugins
  virtualbox
  faugus-launcher
  wine-wayland
  
  ];

  # ── Version ─────────────────────────────────────────────────────
  system.stateVersion = "26.05";


  # ── SSD TRIM ─────────────────────────────────────────────────────
  services.fstrim.enable = true;



  # ── OPEN RGB ─────────────────────────────────────────────────────
 
services.hardware.openrgb = {
  enable = true;
  package = pkgs.openrgb-with-all-plugins;
};
 

  # ── Flake Config  ─────────────────────────────────────────────────────


  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
