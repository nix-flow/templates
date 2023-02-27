{ pkgs ? import <nixpkgs> { } }:
let
  inherit (pkgs) mkShell writeScriptBin;
  exec = pkg: "${pkgs.${pkg}}/bin/${pkg}";
  format = writeScriptBin "format" ''
          ${exec "nixpkgs-fmt"} templates/**/*.nix
        '';
  update = writeScriptBin "update" ''
          for dir in `ls -d templates/*/`; do # Iterate through all the templates
            (
              cd $dir
              ${exec "nix"} flake update # Update flake.lock
              ${exec "direnv"} reload    # Make sure things work after the update
            )
          done
        '';
in
{
  default = mkShell {
    packages = [ format update ];
  };
}
