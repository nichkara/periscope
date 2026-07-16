-- cpu.vhd
-- Created on: Mon 05 Jan 2026 19:09:50 CET
-- Author(s): Nina Chlóe Kassandra Reiß <nina.reiss@nickr.eu>
-- Content:  Entity cpu
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.riscv_types.all;

-- Entity Cpu: Top level entity
entity Cpu is
    port (
        Clock                 : in  std_logic;
        Reset_N               : in  std_logic;
        Interrupt             : in  std_logic;
        Instruction           : in  word;
        Memory_A              : in  word;
        Memory_B              : in  word;
        Instruction_Address   : out word;
        Memory_Address_Read_A : out word;
        Memory_Address_Read_B : out word;
        Memory_Address_Write  : out word;
        Memory_Write          : out word
    );
end entity Cpu;


architecture Implementation of Cpu is

    -- Instruction Fetch

    -- Decode

    -- Operand Fetch
    signal Register_ID_Read_1   : reg_idx;
    signal Register_ID_Read_2   : reg_idx;
    signal Register_Read_Data_1 : word;
    signal Register_Read_Data_2 : word;

    -- Execute

    -- Write Back
    signal Register_Enable      : std_logic;
    signal Register_Write_Data  : word;
    signal Register_ID_Write    : reg_idx;

begin

    Register_Instance: entity work.Register_Cluster(Structure)
    port map (
        Clock              => Clock,
        Reset_N            => Reset_N,
        Write_Data         => Register_Write_Data,
        Register_ID_Write  => Register_ID_Write,
        Register_ID_Read_1 => Register_ID_Read_1,
        Register_ID_Read_2 => Register_ID_Read_2,
        Enable_Writeback   => Register_Enable,
        Read_Data_1        => Register_Read_Data_1,
        Read_Data_2        => Register_Read_Data_2
    );

end architecture Implementation;
