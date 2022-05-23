{
  description = "Samsky flake";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    unstable-nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";	
    home-manager = { 
      url = "github:nix-community/home-manager/release-21.11"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR"; 
  };


  outputs = inputs@{ self, nixpkgs, unstable-nixpkgs, home-manager, nur, ... }: 
    let 
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
      overlay-unstable = final: prev: {
        unstable = import unstable-nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
      
      # Configuration for Lenovo Legion 7
      nixosConfigurations.legion = lib.nixosSystem {
        inherit system;
        modules = [ 
          ./configuration.nix
          ./legion7.nix 
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.samsky = import ./home.nix;   
          }  
          { nixpkgs.overlays = [ nur.overlay 
                                 overlay-unstable]; }
        ];
      };
      
      # Configuration for Acer Helios Predator 500
      nixosConfigurations.predator = lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ./helios500.nix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.samsky = import ./home.nix; 
          }
        ]; 
      }; 
    };
}
