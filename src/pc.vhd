-- Program_Counter.vhd
-- Created on: Mo 05. Dec 14:21:39 CET 2022
-- Author(s): Nina Chloé Kassandra Reiß <nina.reiss@nickr.eu>
-- Content: program counter
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

-- Entity PC: entity defining the pins and ports of the programmcounter
entity Program_Counter is
    port (
        Clock            : in  std_logic;
        Reset_N          : in  std_logic;
        Count_Enable     : in  std_logic;
        Jump_Enable      : in  std_logic;
        External_Address : in  ram_addr_t;
        Jump_Offset      : in  ram_addr_t;
        Updated_Address  : out ram_addr_t
    );

end entity Program_Counter;


architecture Implementation of Program_Counter is
    signal Status : std_logic_vector(2 downto 0);
begin
    process (Clock, Reset_N) is
    begin
        if rising_edge(Clock) then
            case Status is
                when "110" | "111" =>
                    Updated_Address <= (others => '0');
                when "011" =>
                    Updated_Address <= std_logic_vector(signed(External_Address) + signed(Jump_Offset));
                when "010" =>
                    Updated_Address <= std_logic_vector(unsigned(External_Address) + 4);
                when others =>
                    Updated_Address <= External_Address;
            end case;
        end if;
    end process;

    Status                          <= (Reset_N & Count_Enable & Jump_Enable);

end architecture Implementation;
