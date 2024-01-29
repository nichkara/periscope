-- imem.vhd
-- Created on: Do 29. Dez 20:44:53 CET 2022
-- Author(s): Yannick Reiß, Alexander Graf, Carl Ries
-- Content: Entity instruction memory as part of ram
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_types.all;

entity instr_memory is

  generic (initMem : ram_t := (others => (others => '0')));

  port (clk : in std_logic;

        addr_a      : in  std_logic_vector(ram_addr_size - 3 downto 0);
        data_read_a : out std_logic_vector(wordWidth - 1 downto 0);

        write_b      : in  one_bit;
        addr_b       : in  std_logic_vector(ram_addr_size - 3 downto 0);
        data_read_b  : out std_logic_vector(wordWidth - 1 downto 0);
        data_write_b : in  std_logic_vector(wordWidth - 1 downto 0)

        );

end instr_memory;

-- START:
--     addi x1 x0 1
--     add  x2 x0 x0
--     add  x3 x0 x0
--     addi x4 x0 2047
--     slli x4 x4 5
-- REG2UP:
--     add  x2 x2 x1
--     add  x3 x0 x0
-- REG3UP:
--     add  x3 x3 x1
--     bgeu x3 x4 REG2UP
--     jal  REG3UP
architecture behavioral of instr_memory is
  signal store : ram_t :=
    (
      x"00100093", x"00000133", x"000001b3", x"7ff00213", x"00521213", x"00110133", x"000001b3", x"001181b3", x"fe41fae3", x"ff9ff0ef", others => (others => '0')
      );
begin

  -- Two synchron read ports 
  data_read_a <= store(to_integer(unsigned(addr_a(9 downto 2))));
  data_read_b <= store(to_integer(unsigned(addr_b(9 downto 2))));

end behavioral;
