{
  description = "Python uv environment with cuda packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs [ "x86_64-linux" ];
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              python312
              uv
              ninja # Required for compiling the submodules
              gcc13 # C++ Compiler
              cmake

              # Core C-libraries required by PyTorch and PyPI wheels
              stdenv.cc.cc.lib
              zlib
              glib
              libGL
              udev
              gmp
              cgal
              mpfr
              boost

              # Graphics & Windowing libraries
              libx11
              libxext
              libxrender
              libxcb
              libxkbcommon
            ];

            shellHook = ''
              export CC=${pkgs.gcc13}/bin/gcc
              export CXX=${pkgs.gcc13}/bin/g++

              export LD_LIBRARY_PATH=${
                pkgs.lib.makeLibraryPath (
                  with pkgs;
                  [
                    stdenv.cc.cc.lib
                    zlib
                    glib
                    libGL
                    libx11
                    libxext
                    libxrender
                    libxcb
                    libxkbcommon
                    udev
                  ]
                )
              }:$LD_LIBRARY_PATH
            '';
          };
        }
      );
    };
}
