# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  # nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    # export __NV_PRIME_RENDER_OFFLOAD=1
    # export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    # export __GLX_VENDOR_LIBRARY_NAME=nvidia
    # export __VK_LAYER_NV_optimus=NVIDIA_only
    # exec -a "$0" "$@"
  # '';
in
{

  # Allow propreitary software
  nixpkgs.config.allowUnfree = true;

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 8d";

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Lenovo p1 gen 3 hardware quirks
  "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/lenovo/thinkpad/p1/3th-gen"
    ];

  #hardware.video.hidpi.enable = true;
  hardware.bluetooth.enable = true;
  hardware.nvidia.prime = {
    offload.enable = true;
   # sync.enable = true;
  };


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelParams = [ 
  	# "acpi_backlight=vendor"
	# "video.use_native_backlight=0"
	# "nvidia.NVreg_EnableBacklightHandler=1"
  # ];

    networking.hostName = "nixos"; # Define your hostname.
    networking.networkmanager.enable = true;

  # Set your time zone.
    time.timeZone = "America/Chicago";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  networking.hosts = {

	"127.0.0.1" = [ "local.schooldata.net" ];

	"10.1.42.204" = [ "web01" ];
	"10.1.42.14" = [ "work1" ];
	"10.1.43.21" = [ "work2" ];
	"10.1.43.103" = [ "sqldev" ];
	"10.1.43.36" = [ "sql21" ];
	"10.1.43.91" = [ "sql22" ];
	"10.1.43.15" = [ "sql23" ];
	"10.1.43.96" = [ "sql24" ];
	"10.1.43.73" = [ "sql25" ];
	"10.1.43.24" = [ "sql26" ];
	"10.1.43.54" = [ "hrmplus" ];

  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
 i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
      useXkbConfig = true;
    };

    fonts.fonts = with pkgs; [
	nerdfonts
    ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  #services.xserver.dpi = 192;

  # Enable the GNOME Desktop Environment.
    services.xserver = {
	displayManager.lightdm = {
		enable = true;
		greeters.gtk.cursorTheme = {
			name = "Vanilla-DMZ";
			package = pkgs.vanilla-dmz;
			size = 64;
		};
	};

	desktopManager.xfce = {
		enable = true;
		enableXfwm = false;
		noDesktop = true;
	};
	
	windowManager.awesome.enable = true;
    };

  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";
  services.xserver.xkbOptions = "ctrl:swapcaps";

  # Enable CUPS to print documents.
    services.printing.enable = true;

  # Enable sound.
    sound.enable = true;
    hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
    services.xserver.libinput.enable = true;

  # Disable Mouse acceleration
  services.xserver.libinput.touchpad.accelProfile = "flat";
  services.xserver.config = ''
    Section "InputClass"
      Identifier "mouse accel"
      Driver "libinput"
      MatchIsPointer "on"
      Option "AccelProfile" "flat"
      Option "AccelSpeed" "0"
    EndSection
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.matt = {
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };

      environment.variables = {
        EDITOR= "nvim";
        VISUAL= "nvim";
      };
  # List packages installed in system profile. To search, run:
  # $ nix search wget

    environment.systemPackages = with pkgs; [
	home-manager

	pywal

	bc
	ranger
	neovim
	gparted
	alacritty
	zsh
	ffmpeg
	imagemagick
	mplayer
	tree
	tmux
	curl
	feh
	autorandr
	direnv

	unstable.discord
	unstable.brave
	unstable.google-chrome
	unstable.slack
	jetbrains.webstorm
	azuredatastudio
	spotify
	openfortivpn
	git
	unstable.avocode
	qemu
	# need something for s3 and rdp
	#nvidia-offload
    ];

  programs.zsh.enable = true;
  #Enable Oh-my-zsh
  programs.zsh = {
	  ohMyZsh = {
		  enable = true;
		  plugins = [ "git" "sudo" "git" ];
		  theme = "agnoster";
	  };
	  autosuggestions.enable = true;
	  syntaxHighlighting.enable = true;
  };
  

  #environment.variables.XCURSOR_SIZE = "64";
  #environment.variables.GDK_SCALE = "2";
  #environment.variables.GDK_DPI_SCALE = "0.5";
  #environment.variables._JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  #environment.variables.XDG_CONFIG_HOME = "";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
    services.picom = {
	enable = true;
	vSync = true;
    };

    services.blueman.enable = true;

  # Enable the OpenSSH daemon.
    services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

