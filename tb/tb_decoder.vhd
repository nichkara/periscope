-- tb_decoder.vhd
-- Created on: Di 6. Dez 10:50:02 CET 2022
-- Author(s): Yannick Reiß, Car Ries, Alexander Graf
-- Content: Testbench for decoder (NOT AUTOMATED, ONLY STIMULI)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.uniform;

library work;
use work.riscv_types.all;

library std;
use std.textio.all;

-- Entity decoder_tb: dummy entity for decoder
entity decoder_tb is
end decoder_tb;

-- Architecture testingdecoder of decoder_tb: testing instruction decode
architecture testingdecoder of decoder_tb is
  -- clk
  signal clk          : std_logic;
  constant clk_period : time := 10 ns;

  -- inputs
  signal instrDecode : instruction;

  -- outputs
  signal aluOpCode : uOP;
  signal regOp1    : reg_idx;
  signal regOp2    : reg_idx;
  signal regWrite  : reg_idx;
begin
  uut : entity work.decoder(decode)
    port map (
      instrDecode => instrDecode,
      op_code   => aluOpCode,
      regOp1      => regOp1,
      regOp2      => regOp2,
      regWrite    => regWrite);

  -- clk-prog
  clk_process : process                 -- runs only, when  changed
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- Process stim_proc  stimulate uut
  stim_proc : process                   -- runs only, when  changed
    variable lineBuffer : line;
  begin
    write(lineBuffer, string'("Start the simulator"));
    writeline(output, lineBuffer);

    wait for 5 ns;

    -- add x9, x0, x3
    instrDecode <= "00000000001100000000010010110011";
    wait for 10 ns;

    -- add x1, x2, x3
    instrDecode <= "00000000001100010000000010110011";
    wait for 10 ns;

		-- sll x1, x0, x2
		instrDecode <= "00000000001000000001000010110011";
		wait for 10 ns;

		-- sub x6, x3, x1
		instrDecode <= "01000000000100011000001100110011";
		wait for 10 ns;

		-- nop x6, x3, x1
		instrDecode <= "01000000000100011000001100110111";
		wait for 10 ns;

    wait;
  end process;
end testingdecoder;
