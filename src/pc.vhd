-- pc.vhd
-- Created on: Mo 05. Dec 14:21:39 CET 2022
-- Author(s): Nina Chloé Kassandra Reiß <nina.reiss@nickr.eu>
-- Content: program counter
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

-- Entity PC: entity defining the pins and ports of the programmcounter
entity pc is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        en_pc       : in  std_logic;
        doJump      : in  std_logic;
        addr_calc   : in  ram_addr_t;
        jump_offset : in  ram_addr_t;
        addr        : out ram_addr_t
    );

end entity pc;


architecture pro_count of pc is
    signal status : std_logic_vector(2 downto 0);
begin
    process (clk, reset) is
    begin
        if rising_edge(clk) then
            case status is
                when "110" | "111" =>
                    addr <= (others => '0');
                when "011" =>
                    addr <= std_logic_vector(signed(addr_calc) + signed(jump_offset));
                when "010" =>
                    addr <= std_logic_vector(unsigned(addr_calc) + 4);
                when others =>
                    addr <= addr_calc;
            end case;
        end if;
    end process;

    status               <= (reset & en_pc & doJump);

end architecture pro_count;
