-- imem.vhd
-- Created on: Do 29. Dez 20:44:53 CET 2022
-- Author(s): Nina Chloé Kassandra Reiß <nina.reiss@nickr.eu>
-- Content: Entity instruction memory as part of ram
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

entity instr_memory is

    port (
        clk          : in  std_logic;
        addr_a       : in  std_logic_vector(ram_addr_size - 3 downto 0);
        data_read_a  : out std_logic_vector(wordWidth - 1 downto 0);
        write_b      : in  std_logic;
        addr_b       : in  std_logic_vector(ram_addr_size - 3 downto 0);
        data_read_b  : out std_logic_vector(wordWidth - 1 downto 0);
        data_write_b : in  std_logic_vector(wordWidth - 1 downto 0)
    );

end entity instr_memory;

architecture behavioral of instr_memory is
    signal store : ram_t;
begin

    store                   <=
        (
            b"00000000000000000000001010010011",
            b"00000000000100101000001010010011",
            b"11111111110111111111000011101111",
            others => (others => '0')
        );

    -- Process synchron read and write
    synchron_rw: process (clk) is -- runs only, when clk changed
    begin
        if rising_edge(clk) then

            -- Two synchron read ports
            data_read_a     <= store(to_integer(unsigned(addr_a(14 downto 2))));
            if write_b then
                data_read_b <= data_write_b;
            else
                data_read_b <= store(to_integer(unsigned(addr_b(14 downto 2))));
            end if;

        end if;
    end process synchron_rw;

end architecture behavioral;
