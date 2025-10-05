{
  description = "nullspace NixOS + Home Manager + Nixcord";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  # Sync HM to unstable nixpkgs
    nixcord.url = "github:KaylorBen/nixcord";  # Your linked repo
  };

  outputs = { self, nixpkgs, home-manager, nixcord, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.nullspace = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Global nixpkgs config (allowUnfree if needed for packages/Discord)
          {
            nixpkgs.config.allowUnfree = true;
          }

          ./configuration.nix

          # Home Manager as NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit nixcord; };  # Pass nixcord for HM access if needed

            home-manager.users.user = {
              imports = [
                ./home.nix
                nixcord.homeModules.nixcord  # Correct structured import for nixcord HM module
              ];
              home.username = "user";
              home.homeDirectory = "/home/user";
            };
          }
        ];
      };

      # Optional: Standalone HM for testing
      homeConfigurations."user@nullspace" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit nixcord; };
        modules = [
          ./home.nix
          nixcord.homeModules.nixcord  # Same structured import
        ];
      };
    };
}
