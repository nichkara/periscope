library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_types.all;

library std;
use std.textio.all;

entity cpu_tb is
end cpu_tb;

architecture Behavioral of cpu_tb is

  -- Clock
  signal clk : std_logic;

  -- Inputs

  -- Outputs
  -- Clock period definitions
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : entity work.cpu(implementation)
    port map (clk => clk);

  -- Clock process definitions
  clk_process : process
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

    wait;
  end process;
end architecture;
