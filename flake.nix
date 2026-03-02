{
  description = "Custom RV32I VHDL CPU (GHDL + FPGA + RISC-V toolchain)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    riscv = pkgs.pkgsCross.riscv32-embedded;
  in
  {
    # ==========================
    # Dev Shell
    # ==========================
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        # Build system
        pkgs.gnumake
        pkgs.python3
        pkgs.which
        pkgs.coreutils   # hexdump

        # VHDL
        pkgs.ghdl

        # FPGA (Gowin / TangNano9K)
        pkgs.yosys
        pkgs.nextpnr
        pkgs.openFPGALoader
        pkgs.gowin-pack

        # RISC-V toolchain
        riscv.buildPackages.gcc
        riscv.buildPackages.binutils
        riscv.buildPackages.newlib
      ];

      shellHook = ''
        export RISCV_PREFIX=riscv32-unknown-elf
        echo "RV32I DevShell ready"
        echo "Toolchain:"
        riscv32-unknown-elf-gcc --version | head -n1
      '';
    };

    # ==========================
    # nix run  -> make all
    # ==========================
    apps.${system}.default = {
      type = "app";
      program = toString (pkgs.writeShellScript "run-make-all" ''
        exec ${pkgs.gnumake}/bin/make all
      '');
    };

    # ==========================
    # nix run .#simulation
    # ==========================
    apps.${system}.simulation = {
      type = "app";
      program = toString (pkgs.writeShellScript "run-simulation" ''
        exec ${pkgs.gnumake}/bin/make simulation
      '');
    };
  };
}
