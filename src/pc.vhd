-- pc.vhd
-- Created on: Mo 05. Dec 14:21:39 CET 2022
-- Author(s): Carl Ries, Yannick Reiß, Alexander Graf
-- Content: program counter
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_types.all;

-- Entity PC: entity defining the pins and ports of the programmcounter
entity pc is
  port (clk       : in  std_logic;      -- Clock input for timing
        en_pc     : in  one_bit;        -- activates PC
        addr_calc : in  ram_addr_t;     -- Address from ALU
        doJump    : in  one_bit;        -- Jump to Address
        addr      : out ram_addr_t      -- Address to Decoder
    );

end PC;


architecture pro_count of pc is
    signal addr_out : ram_addr_t := (others => '0');
    signal addr_out_plus : ram_addr_t := (others => '0');
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if en_pc = "1" then
        -- count 
        if doJump = "1" then 
            addr_out <= addr_calc;
        -- jump
        else
            addr_out <= addr_out_plus;
        end if;
      end if;
    end if;
  end process;
  
  addr_out_plus <= (std_logic_vector(to_unsigned(to_integer(unsigned(addr_out)) + 4, ram_addr_size)));
  addr <= addr_out;
  
end pro_count;
