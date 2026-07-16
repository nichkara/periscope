-- tb_decoder.vhd
-- Created on: Di 6. Dez 10:50:02 CET 2022
-- Author(s): Nina Chlóe Kassandra Reiß <nina.reiss@nickr.eu>
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
end entity decoder_tb;

-- Architecture testingdecoder of decoder_tb: testing instruction decode

architecture testingdecoder of decoder_tb is

  -- clk
  signal   clk        : std_logic;
  constant clk_period : time := 10 ns;

  -- inputs
  signal instrdecode : instruction;

  -- outputs
  signal aluopcode : uop;
  signal regop1    : reg_idx;
  signal regop2    : reg_idx;
  signal regwrite  : reg_idx;

begin

  uut : entity work.decoder(decode)
    port map (
      raw_instruction    => instrdecode,
      operation          => aluopcode,
      operand_register_1 => regop1,
      operand_register_2 => regop2,
      write_register     => regwrite
    );

  -- clk-prog
  clk_process : process is -- runs only, when  changed
  begin

    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;

  end process clk_process;

  -- Process stim_proc  stimulate uut
  stim_proc : process is   -- runs only, when  changed

    variable linebuffer : line;

  begin

    write(linebuffer, string'("Start the simulator"));
    writeline(output, linebuffer);

    wait for 5 ns;

    -- add x9, x0, x3
    instrdecode <= "00000000001100000000010010110011";
    wait for 10 ns;

    -- add x1, x2, x3
    instrdecode <= "00000000001100010000000010110011";
    wait for 10 ns;

    -- sll x1, x0, x2
    instrdecode <= "00000000001000000001000010110011";
    wait for 10 ns;

    -- sub x6, x3, x1
    instrdecode <= "01000000000100011000001100110011";
    wait for 10 ns;

    -- nop x6, x3, x1
    instrdecode <= "01000000000100011000001100110111";
    wait for 10 ns;

    wait;

  end process stim_proc;

end architecture testingdecoder;
