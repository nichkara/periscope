-- tb_cpu.vhd
-- Created on: Di 6. Dez 10:50:02 CET 2022
-- Author(s): Nina Chlóe Kassandra Reiß <nina.reiss@nickr.eu>
-- Content: Testbench with simulated soc and self verifying program

-- ----------------------------------
-- SOC Configuration:
--   - 1 CPU
--   - 1 Memory instance (32 Blocks)
--   - 1 Sound Card Block
--   - 2 Graphics Card Blocks
--   - 1 eFPGA-Dummy
-- ----------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.uniform;

use work.riscv_types.all;

library std;
use std.textio.all;

-- Entity cpu_tb: dummy entity for cpu
entity cpu_tb is
end entity cpu_tb;

-- Architecture testingcpu of cpu_tb: testing instruction decode
architecture Testbench of cpu_tb is
    -- clk
    constant Clock_Period        : time := 10 ns;
    signal Clock_Emulation       : std_logic;
    signal Reset_Emulation       : std_logic;

    -- inputs
    signal Interrupt             : std_logic;
    signal Instruction           : word;
    signal Memory_A              : word;
    signal Memory_b              : word;

    -- outputs
    signal Instruction_Address   : word;
    signal Memory_Address_Read_A : word;
    signal Memory_Address_Read_B : word;
    signal Memory_Address_Write  : word;
    signal Memory_Write          : word;

begin
    Uut: entity work.Cpu(Implementation)
    port map (
        Clock                 => Clock_Emulation,
        Reset_N               => Reset_Emulation,
        Interrupt             => Interrupt,
        Instruction           => Instruction,
        Memory_A              => Memory_A,
        Memory_B              => Memory_B,
        Instruction_Address   => Instruction_Address,
        Memory_Address_Read_A => Memory_Address_Read_A,
        Memory_Address_Read_B => Memory_Address_Read_B,
        Memory_Address_Write  => Memory_Address_Write,
        Memory_Write          => Memory_Write
    );

    Clock_Signal_Emulation: process
    begin
        Clock_Emulation <= '0';
        wait for Clock_Period / 2;
        Clock_Emulation <= '1';
        wait for Clock_Period / 2;
    end process Clock_Signal_Emulation;

    Simulation: process
        variable Line_Buffer     : line;
    begin
        write(Line_Buffer, string'("Start the simulator"));
        writeline(output, Line_Buffer);

        Reset_Emulation <= '1';
        wait until rising_edge(Clock_Emulation);
        Reset_Emulation <= '0';

        wait for 5 ns;
        Reset_Emulation <= '1';

        wait;
    end process Simulation;
end architecture Testbench;
