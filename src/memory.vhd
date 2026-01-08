-- Created on: Do 3. Nov 20:11:50 CET 2022
-- Author(s): Nina Chloé Kassandra Reiß <nina.reiss@nickr.eu>
-- Content: Entity ram and architecture of ram
use work.riscv_types.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
    port (
        Clock                   : in  std_logic;
        Reset_N                 : in  std_logic;
        Instruction_Address     : in  ram_addr_t;
        Data_Address            : in  ram_addr_t;
        Enable_Memory_Writeback : in  std_logic;
        Write_Data              : in  word;
        Read_Instruction        : out word;
        Read_Data               : out word
    );
end entity Memory;


architecture Simulation of Memory is

    constant Block_Count             : Integer := 4194304;
    type Block_Mux_Cluster is array (0 to Block_Count - 1) of word;

    signal Block_Enable              : std_logic_vector(Block_Count - 1 downto 0);
    signal Block_Instruction_Address : std_logic_vector(9 downto 0);
    signal Block_Data_Address        : std_logic_vector(9 downto 0);
    signal Instruction_Mux           : Block_Mux_Cluster;
    signal Data_Mux                  : Block_Mux_Cluster;

begin

    Bios_Block: entity work.Memory_Block(Read_Only)
    port map (
        Clock                       => Clock,
        Reset_N                     => Reset_N,
        Enable_Memory_Writeback     => Block_Enable(0),
        Memory_Address_A            => Block_Instruction_Address,
        Memory_Address_B            => Block_Data_Address,
        Memory_Read_A               => Instruction_Mux(0),
        Memory_Read_B               => Data_Mux(0),
        Memory_Write                => Write_Data
    );

    RAM_Cluster: for I in 1 to Block_Count - 1 generate
        RAM_Block: entity work.Memory_Block(Random_Access)
        port map (
            Clock                   => Clock,
            Reset_N                 => Reset_N,
            Enable_Memory_Writeback => Block_Enable(I),
            Memory_Address_A        => Block_Instruction_Address,
            Memory_Address_B        => Block_Data_Address,
            Memory_Read_A           => Instruction_Mux(I),
            Memory_Read_B           => Data_Mux(I),
            Memory_Write            => Write_Data
        );
    end generate;

    -- MUX Selectors
    Read_Instruction          <= Instruction_Mux(to_integer(unsigned(Instruction_Address(31 downto 10))));
    Read_Data                 <= Data_Mux(to_integer(unsigned(Data_Address(31 downto 10))));
    Write_Enable_For_Cluster: for I in 1 to Block_Count - 1 generate
        Block_Enable(I) <= Enable_Memory_Writeback when (I = to_integer(unsigned(Data_Address(31 downto 19)))) else '0';
    end generate;

    -- Bus selector
    Block_Instruction_Address <= Instruction_Address(9 downto 0);
    Block_Data_Address        <= Data_Address(9 downto 0);

end architecture Simulation;
