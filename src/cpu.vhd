-- cpu.vhd
-- Created on: Mon 05 Jan 2026 19:09:50 CET
-- Author(s): Nina Chloé Kassandra Reiß <nina.reiss@nickr.eu>
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
begin

end architecture Implementation;
