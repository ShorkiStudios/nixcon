{
  description = "nullspace NixOS + Home Manager + Nixcord";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord.url = "github:KaylorBen/nixcord/0a5f5936fa40650e3869c705ddbff6e1a72c89db";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";  # Ensures compatibility with your nixpkgs (25.05)
    };
  };

  outputs = { self, nixpkgs, home-manager, nixcord, zen-browser, ... }:
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
          {
            # Pass zen-browser to configuration.nix
            _module.args.zen-browser = zen-browser;
          }
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
