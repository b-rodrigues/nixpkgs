let
 pkgs = import (fetchTarball "https://github.com/b-rodrigues/nixpkgs/archive/06b93631a20bc9c1e73d7b5c706af12ee01922aa.tar.gz") {};
 system_packages = builtins.attrValues {
  inherit (pkgs) git wget cacert glibcLocalesUtf8 nix R;
};
  in
  pkgs.mkShell {
    LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then  "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive" else "";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";

    buildInputs = [
      system_packages
      pkgs.rPackages.data_table
      pkgs.rPackages.BiocManager
                  ];

  }
