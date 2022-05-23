{ pkgs, nixpkgs, ... }: {

  home.packages = with pkgs; [
#    citrix_workspace
    cmake
    gcc
    gdb
    nasm
    nmap
    nmapsi4
    nur.repos.xddxdd.svp
    python
    teams
    testssl
    qt5Full
    qtcreator
    zoom-us
  ];
  
  # Configuration for dxvk for nvidia
  home.file.".config/dxvk.conf".text = ''
    dxgi.nvapiHack = False
  '';

  # Configuration of mpv to use Vapoursynth script for 60 fps  
  home.file.".config/mpv/mpv.conf".text = ''
    vf=format=yuv420p,vapoursynth=~~/mvt.vpy:4:4 
  '';

  # Script for converting video to motion interpolation with 60 fps on the fly 
  home.file.".config/mpv/mvt.vpy".text = ''
  # vim: set ft=python:

  import vapoursynth as vs
  core = vs.core
  if "video_in" in globals():
    clip = video_in

    dst_fps = 60
    # Interpolating to fps higher than 60 is too CPU-expensive, smoothmotion can handle the rest.
    # while (dst_fps > 60):
    #   dst_fps /= 2

    # Skip interpolation for >1080p or 60 Hz content due to performance
    if not (clip.width > 1920 or clip.height > 1080 or container_fps > 70):
      src_fps_num = int(container_fps * 1e8)
      src_fps_den = int(1e8)
      dst_fps_num = int(dst_fps * 1e4)
      dst_fps_den = int(1e4)
      # Needed because clip FPS is missing
      clip = core.std.AssumeFPS(clip, fpsnum = src_fps_num, fpsden = src_fps_den)
      print("Reflowing from ",src_fps_num/src_fps_den," fps to ",dst_fps_num/dst_fps_den," fps.")

      sup  = core.mv.Super(clip, pel=2, hpad=16, vpad=16)
      bvec = core.mv.Analyse(sup, blksize=16, isb=True , chroma=True, search=3, searchparam=1)
      fvec = core.mv.Analyse(sup, blksize=16, isb=False, chroma=True, search=3, searchparam=1)
      clip = core.mv.BlockFPS(clip, sup, bvec, fvec, num=dst_fps_num, den=dst_fps_den, mode=3, thscd2=12)

      clip.set_output()
  '';

  home.file.".config/mpv/mvt.vpy".executable = true;

  nixpkgs.config.allowUnfree = true;

  programs = {
    
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      autocd = true;
      shellAliases = {
        ll = "ls -lah";
        ytd = "yt-dlp -f \"(bv*[vcodec~='^((he|a)vc|h26[45])']+ba) / (bv*+ba/b)\" ";
        ncg = "sudo nix-collect-garbage -d";
      };
      oh-my-zsh = {
        enable = true;
        theme = "jonathan";
      }; 
    };
    
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
        YouCompleteMe
      ]; 
      extraConfig = ''
        :set number
      '';
    };    

    # Override mpv for 60 fps
    mpv = {
      enable = true;
      package = with pkgs; wrapMpv (mpv-unwrapped.override {
        vapoursynthSupport = true;
        vapoursynth = vapoursynth.withPlugins ([
        vapoursynth-mvtools   
        ]);  
      }) { youtubeSupport = true; };
    };
  };
}
