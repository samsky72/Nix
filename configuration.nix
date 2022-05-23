# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
  #    ./hardware-configuration.nix
  #    <home-manager/nixos>
    ];

  # The Nix configuration.
  nix = {
    
    # Flakes init
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    
    # Set auto garbage collection
    gc = {
      dates = "weekly";
      automatic = true;
      options = "--older-than 30d"
    };
    
    # Set auto optimise nix store 
    optimise = {
      dates = [
        "weekly"
      ];
      automatic = true;
    };
    
    # Set jobs count 
    maxJobs = 12;
  };
     
    
  boot = {
    
    # Use th systemd-boot EFI boot loader.
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi  = {
        canTouchEfiVariables = true;
      };
    };
    
    # Define supported file systems.
    supportedFilesystems = [
      "ntfs"
      "vfat"
    ];
 
    # Enable mapping of tmp on tmpfs.  
    tmpOnTmpfs = true;
  };
  

  # The SystemD configuration 
  systemd = { 
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };  
 
  networking = { 
    
    # Enable Network Manager.
    networkmanager = {
      enable = true;
    };

    # Enable firewall.
    firewall = {
      enable= true;
      allowedTCPPorts = [80 443 3000 3001 3802 6250 6969];
      allowedUDPPorts = [80 443 3000 3001 3802 6250 6969];
    }; 
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time = {
    timeZone = "Asia/Oral";
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  nixpkgs = {
   
   # Allow non free software. 
   config = {
      allowUnfree = true;
    };
   
    overlays = [
     (final: prev: {
       # Add CUDA support for blender.
       blender = prev.unstable.blender.override { 
         cudaSupport = true;
         colladaSupport = true;
       };
     })
   ];
  }; 


  # Select internationalisation properties.
  i18n = { 
    defaultLocale = "en_US.UTF-8";
  }; 
  
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services = { 
    xserver = {
      enable = true;
  
      # Enable the Plasma 5 Desktop Environment.
      displayManager = {
        sddm = { 
          enable = true;
        };
      };
      desktopManager = {
        plasma5 = {
          enable = true;
       };
     };
    
      # Configure keymap in X11.
      layout = "us, ru";
      xkbOptions = "grp:alt_shift_toggle";
 
      # Enable touchpad support (enabled default in most desktopManager).
      libinput = {
        enable = true;
      };
    };
    
    # Enable tor
    tor = {
      client = {
        enable = true;
      }; 
      enable = true;
      openFirewall = true;
    };
    
    # Make tor as proxy
    privoxy = {
      enable = true;
      enableTor = true;
    }; 
  };
  
  # Fonts configuration
  fonts = {
    enableDefaultFonts = true;
    enableGhostscriptFonts = true;
    fontDir = {
      enable = true;
    };
    fonts = with pkgs; [
      iosevka
    ];
    fontconfig = {
      enable = true;
      subpixel = {
        lcdfilter = "default";
      };   
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound = {
    enable = true;
  };

  # Some hardware configuration.
  hardware = {
    
    pulseaudio = {
      enable = true;
    };
    
    bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
    };
    
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      setLdLibraryPath = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ]; 
    };
  };
 

  # Define a user account..
  users = {
    users = { 
      samsky = {
        isNormalUser = true;
        createHome = true;
        initialPassword = "Password100";
        extraGroups = [ "audio" "video" "wheel" "networkmanager" "wireshark" "adbusers" "vboxusers"]; # Enable ‘sudo’ for the user.
        shell = pkgs.zsh;
      };
    };
  };

  # Enable VirtualBox with Oracle Extension Pack
  virtualisation = {
    virtualbox = {
      host = { 
        enable = true;
        enableExtensionPack = true;
      };
    };
  }; 
  
  
   
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      ark
      audacity
      avidemux
      blender
      calligra
      clementine
      cudatoolkit
      dislocker
      djvulibre
      dosbox
      eiskaltdcpp
      firefox
      ffmpeg
      ghostscript
      gimp
      glxinfo
      google-chrome
      lmms
      kate
      kcalc
      kdenlive
      kgpg
      krita
      krename
      ksystemlog
      libreoffice
      lshw
      mc
      mpv
      neofetch
      nixops
      unstable.nix-update
      nox
      obs-studio
      unstable.obs-studio-plugins.obs-vkcapture
      pciutils
      psmisc
      qbittorrent
      smplayer
      smtube
      steam-run-native
      timidity
      tor
      tor-browser-bundle-bin
      unrar
      vapoursynth
      vim
      vulkan-tools
      vuze
      wget
      wineWowPackages.staging
      youtube-dl
      yt-dlp
    ];
   sessionVariables = {
     DXVK_CONFIG_FILE="\${HOME}/.config/dxvk.conf"; 
   };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
    programs = { 
      steam = {
        enable = true;
      };
      atop = {
        enable = true;
      };
      htop = {
        enable = true;  
      };
      adb = {
        enable = true;
      };
      zsh = {
        enable = true;
      };
      kdeconnect = {
        enable = true;
      };
      wireshark = {
        enable = true;
        package = pkgs.wireshark-qt;
      };
      cdemu = {
        enable = true;
        gui = true;
      };
      git = {
        enable = true;
      };
      traceroute = {
        enable = true;
      };
      java = {
        enable = true;
        package = pkgs.jre;
      };
    };

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = { 
    stateVersion = "21.11"; # Did you read the comment?
  };
}

