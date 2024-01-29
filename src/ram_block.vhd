-- ram_block.vhd
-- Created on: Do 3. Nov 20:06:13 CET 2022
-- Author(s): Alexander Graf, Carl Ries, Yannick Reiß
-- Content:  Entity ram_block
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_types.all;

entity ram_block is

  generic (initMem : ram_t := (others => (others => '0')));

  port (clk : in std_logic;

        addr_a      : in  std_logic_vector(ram_addr_size - 3 downto 0);
        data_read_a : out std_logic_vector(wordWidth - 1 downto 0);

        write_b      : in  one_bit;
        addr_b       : in  std_logic_vector(ram_addr_size - 3 downto 0);
        data_read_b  : out std_logic_vector(wordWidth - 1 downto 0);
        data_write_b : in  std_logic_vector(wordWidth - 1 downto 0)

        );

end ram_block;

--
architecture behavioral of ram_block is

  signal store : ram_t := initMem;

begin

  process(clk)
  begin
    if rising_edge(clk) then

      -- One synchron write port
      if write_b = "1" then
        store(to_integer(unsigned(addr_b(9 downto 2)))) <= data_write_b;
      end if;

    end if;
  end process;

  -- Two synchron read ports 
  data_read_a <= store(to_integer(unsigned(addr_a(9 downto 2))));
  data_read_b <= store(to_integer(unsigned(addr_b(9 downto 2))));

end behavioral;

