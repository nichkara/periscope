-- Memory_Block.vhd
-- Created on: Do 3. Nov 20:06:13 CET 2022
-- Author(s): Nina Chloé Kassandra Reiß <nina.reiss@nickr.eu>
-- Content:  Entity Memory_Block: These are aligned to match the 1024x32 Bit SRAM cells from IHP-Open-PDK



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

entity Memory_Block is

    generic (
        Empty_Memory            :     ram_t := (others => (others => '0'))
    );

    port (
        Clock                   : in  std_logic;
        Reset_N                 : in  std_logic;
        Memory_Address_A        : in  std_logic_vector(9 downto 0);
        Memory_Read_A           : out std_logic_vector(wordWidth - 1 downto 0);
        Enable_Memory_Writeback : in  std_logic;
        Memory_Address_B        : in  std_logic_vector(9 downto 0);
        Memory_Read_B           : out std_logic_vector(wordWidth - 1 downto 0);
        Memory_Write            : in  std_logic_vector(wordWidth - 1 downto 0)
    );

end entity Memory_Block;

architecture Random_Access of Memory_Block is

    signal Memory : ram_t;

begin

    process (Clock) is
    begin
        if rising_edge(Clock) then

            if Reset_N = '0' then
                Memory                                                         <= Empty_Memory;
            else
                if Enable_Memory_Writeback = '1' then
                    Memory(to_integer(unsigned(Memory_Address_B(9 downto 2)))) <= Memory_Write;
                end if;
            end if;
        end if;
    end process;
    Memory_Read_A                                                              <= Memory(to_integer(unsigned(Memory_Address_A(9 downto 2))));
    Memory_Read_B                                                              <= Memory(to_integer(unsigned(Memory_Address_B(9 downto 2))));

end architecture Random_Access;

architecture Read_Only of Memory_Block is

    -- Used for hardcoded BIOS implementation



    signal Read_Only_Memory : ram_t;

begin

    process (Clock) is
    begin
        if rising_edge(Clock) then

            if Reset_N = '0' then
                Read_Only_Memory <= work.Bios.Rom;
            end if;
        end if;
    end process;
    Memory_Read_A                <= Read_Only_Memory(to_integer(unsigned(Memory_Address_A(9 downto 2))));
    Memory_Read_B                <= Read_Only_Memory(to_integer(unsigned(Memory_Address_B(9 downto 2))));

end architecture Read_Only;
