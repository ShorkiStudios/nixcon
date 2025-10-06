{
  description = "nullspace NixOS + Home Manager + Nixcord";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord.url = "github:KaylorBen/nixcord/0a5f5936fa40650e3869c705ddbff6e1a72c89db";
  };

  outputs = { self, nixpkgs, home-manager, nixcord, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.nullspace = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            nixpkgs.config.allowUnfree = true;
          }
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit nixcord; };
            home-manager.users.user = {
              imports = [
                ./home.nix
                nixcord.homeModules.nixcord
              ];
              home.username = "user";
              home.homeDirectory = "/home/user";
            };
          }
        ];
      };
      homeConfigurations."user@nullspace" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit nixcord; };
        modules = [
          ./home.nix
          nixcord.homeModules.nixcord
        ];
      };
    };
}
