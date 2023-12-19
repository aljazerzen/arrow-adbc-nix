# Nix flake for Apache ADBC

Nix flakes for building Apache ADBC libraries and development environment for the project.

Disclaimer: this project is not associated with Apache Foundation.

Prerequisites:

- installed [nix, the package manager](https://nixos.org/download)
- enabled [nix flakes](https://nixos.wiki/wiki/Flakes)

```
nix build github:aljazerzen/arrow-adbc-nix#driver_manager
nix build github:aljazerzen/arrow-adbc-nix#driver_postgresql
nix build github:aljazerzen/arrow-adbc-nix#driver_sqlite
```
