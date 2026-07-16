library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_types.all;

package Bios is
  constant Rom : ram_t := (
    0 => x"ff010113",
    1 => x"00112623",
    2 => x"00812423",
    3 => x"01010413",
    4 => x"00000793",
    5 => x"00078513",
    6 => x"00c12083",
    7 => x"00812403",
    8 => x"01010113",
    9 => x"00008067",
    others => x"00000013"
  );
end package Bios;
