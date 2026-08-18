{ pkgs }:
let
  lib = pkgs.lib;
  dirContent = builtins.attrNames (builtins.readDir ./.);
  pluginFiles = lib.lists.remove "default.nix" (builtins.filter (f: (lib.strings.hasSuffix ".nix" f)) dirContent);
  plugins = map (f: {
    name = builtins.substring 0 (builtins.stringLength f - 4) f;
    value = pkgs.callPackage ( ./. + ("/" + f)) {};
  }) pluginFiles;
in builtins.listToAttrs plugins
