-- tb_imm.vhd
-- Created on: Tu 10. Jan 21:10:00 CET 2023
-- Author(s): Yannick Reiß
-- Content: testbench for immediate entity
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.riscv_types.all;

library std;
use std.textio.all;

-- Entity imm_tb: dummy entity
    entity imm_tb is
    end imm_tb;

architecture testing of imm_tb is

    -- clock definition
    signal clk          : std_logic;
    constant clk_period : time := 10 ns;

    -- inputs imm
    signal s_instruction : instruction;
    signal s_opcode      : uOP;

    -- outputs imm
    signal s_immediate : word;

begin
    uut : entity work.imm
        port map(
            
            instruction => s_instruction,
            opcode      => s_opcode,
            immediate   => s_immediate
            );

    -- Process clk_process  operating the clock
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- stimulation process
    stim_proc : process
        variable lineBuffer : line;
    begin
        -- wait for the rising edge
        wait until rising_edge(clk);

        wait for 10 ns;

        write(lineBuffer, string'("Start the simulator"));
        writeline(output, lineBuffer);

        -- testcases
        -- addi x3, x0, 5
        s_instruction <= x"00500193";
        s_opcode      <= uADDI;

        wait for 10 ns;
        
        -- addi x2, x0, 1
        s_instruction <= x"00100113";
        s_opcode <= uADDI;

        wait;

    end process;

end architecture;  -- testing
