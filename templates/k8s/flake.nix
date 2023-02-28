{
  description = "A Nix-flake-based k8s development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs systems;
      forAllSystems = genAttrs systems.flakeExposed;
      pkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
      });
    in
    {
      devShells = forAllSystems (s:
        let pkgs = pkgsFor.${s}; in
        rec {
          default = pkgs.mkShell {
            KUBECONFIG = ".kube/config";
            packages = with pkgs; [
              kubectl
              kubectx
            ];

            shellHook = ''
              echo "node `${pkgs.kubectl}/bin/kubectl version`"
            '';
          };
        });
    };
}
