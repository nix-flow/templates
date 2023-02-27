{
  description = "A Nix-flake-based Node.js development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs systems;
      forAllSystems = genAttrs systems.flakeExposed;
      pkgsFor = forAllSystems (system: import nixpkgs {
        inherit system; overlays = [ self.overlays.default ];
      });
    in
    {
      overlays = rec {
        default = final: prev: {
          nodejs = prev.nodejs-18_x;
          pnpm = prev.nodePackages.pnpm;
          yarn = (prev.yarn.override { inherit (final) nodejs; });
        };
      };
      devShells = forAllSystems (s:
        let pkgs = pkgsFor.${s}; in
        rec {
          default = pkgs.mkShell {
            packages = with pkgs; [ node2nix nodejs pnpm yarn ];

            shellHook = ''
              echo "node `${pkgs.nodejs}/bin/node --version`"
            '';
          };
        });
    };
}
