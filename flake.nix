{
  description = "Arrow ADBC";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        cpp = with pkgs; [
          cmake
          gtest # >=1.10.0
          postgresql # only for libpq, see https://github.com/NixOS/nixpkgs/pull/234470
          sqlite
          ninja
          pkg-config
          go
        ];

        cpp-lint = with pkgs; [
          clang # =14
          clang-tools # =14
        ];

        dev = with pkgs; [
          commitizen
          gh # >=2.32.0
          jq
          pre-commit
          twine
        ];

        adbc_version = "0.9";
        adbc_src = pkgs.fetchFromGitHub {
          owner = "apache";
          repo = "arrow-adbc";
          rev = "apache-arrow-adbc-0.8.0";
          sha256 = "sha256-wPf5w8sqjRdT/VYdYdkLoDiBBqVTyfz/FlUuAX5lEs8=";
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = dev ++ cpp ++ cpp-lint;
        };

        packages.driver_manager = pkgs.stdenv.mkDerivation rec {
          name = "adbc_postgresql-${version}";
          version = adbc_version;
          src = adbc_src;

          nativeBuildInputs = [ pkgs.cmake pkgs.ninja ];
          buildInputs = [ pkgs.pkg-config ];

          configurePhase = ''
            mkdir build/
            cd build/
            cmake ../c -DADBC_DRIVER_MANAGER=ON
            cd ..
          '';

          buildPhase = ''
            cmake --build build
          '';

          installPhase = ''
            cmake --install build --prefix $out
          '';
        };

        packages.driver_flightsql = pkgs.stdenv.mkDerivation rec {
          name = "adbc_driver_flightsql-${version}";
          version = adbc_version;
          src = adbc_src;

          nativeBuildInputs = [ pkgs.cmake pkgs.ninja ];
          buildInputs = [ pkgs.pkg-config pkgs.go ];

          configurePhase = ''
            mkdir build/
            cd build/
            cmake ../c -DADBC_DRIVER_FLIGHTSQL=ON
            cd ..
          '';

          # TODO: this does not work yet, as it tries to download
          # dependencies from within a flake build.
          # See https://xeiaso.net/blog/nix-flakes-go-programs/
          buildPhase = ''
            HOME=$TMPDIR cmake --build build
          '';

          installPhase = ''
            cmake --install build --prefix $out
            mkdir -p $out/include && cp adbc.h $out/include
          '';
        };

        packages.driver_postgresql = pkgs.stdenv.mkDerivation rec {
          name = "adbc_postgresql-${version}";
          version = adbc_version;
          src = adbc_src;

          nativeBuildInputs = [ pkgs.cmake pkgs.ninja ];
          buildInputs = [ pkgs.pkg-config pkgs.postgresql ];

          configurePhase = ''
            mkdir build/
            cd build/
            cmake ../c -DADBC_DRIVER_POSTGRESQL=ON
            cd ..
          '';

          buildPhase = ''
            cmake --build build
          '';

          installPhase = ''
            cmake --install build --prefix $out
            mkdir -p $out/include && cp adbc.h $out/include
          '';
        };

        packages.driver_sqlite = pkgs.stdenv.mkDerivation rec {
          name = "adbc_sqlite-${version}";
          version = adbc_version;
          src = adbc_src;

          nativeBuildInputs = [ pkgs.cmake pkgs.ninja ];
          buildInputs = [ pkgs.pkg-config pkgs.sqlite ];

          configurePhase = ''
            mkdir build/
            cd build/
            cmake ../c -DADBC_DRIVER_SQLITE=ON
            cd ..
          '';

          buildPhase = ''
            cmake --build build
          '';

          installPhase = ''
            cmake --install build --prefix $out
            mkdir -p $out/include && cp adbc.h $out/include
          '';
        };

        packages.driver_snowflake = pkgs.stdenv.mkDerivation rec {
          name = "adbc_snowflake-${version}";
          version = adbc_version;
          src = adbc_src;

          nativeBuildInputs = [ pkgs.cmake pkgs.ninja ];
          buildInputs = [ pkgs.pkg-config pkgs.go ];

          configurePhase = ''
            mkdir build/
            cd build/
            cmake ../c -DADBC_DRIVER_SNOWFLAKE=ON
            cd ..
          '';

          # TODO: go build (see driver_flightsql)
          buildPhase = ''
            HOME=$TMPDIR cmake --build build
          '';

          installPhase = ''
            cmake --install build --prefix $out
            mkdir -p $out/include && cp adbc.h $out/include
          '';
        };
      });
}
