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

  -- Clock and Reset
  signal clk : std_logic;

  -- Outputs
  -- Clock period definitions
  constant clk_period : time := 10 ns;

  -- CPU and RAM constraints
  signal cpu_reset           : std_logic  := '0';
  signal cpu_instruction     : word       := (others => '0');
  signal cpu_data            : word       := (others => '0');
  signal ram_enable          : std_logic  := '0';
  signal instr_pointer       : ram_addr_t := (others => '0');
  signal ram_address         : ram_addr_t := (others => '0');
  signal ram_data            : word       := (others => '0');
  signal ram_cut_zeros       : ram_addr_t := (others => '0');
  signal instr_pointer_zeros : ram_addr_t := (others => '0');

begin

  ram_cut_zeros       <= "00000000000000000000" & ram_address(11 downto 0);
  instr_pointer_zeros <= "00000000000000000000" & instr_pointer(11 downto 0);

  -- Instantiate the Unit Under Test (UUT)
  uut : entity work.cpu(implementation)
    port map (clk                 => clk,
              rst                 => cpu_reset,
              instruction_read    => cpu_instruction,
              ram_read_data       => cpu_data,
              ram_enable_writing  => ram_enable,
              instruction_pointer => instr_pointer,
              data_address        => ram_address,
              ram_write_data      => ram_data
              );

  rut : entity work.ram (behavioral)
    port map(clk             => clk,
             instructionAddr => instr_pointer_zeros,
             dataAddr        => ram_cut_zeros,
             writeEnable     => ram_enable,
             dataIn          => ram_data,
             instruction     => cpu_instruction,
             dataOut         => cpu_data
             );

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

    wait for 100 ns;
    cpu_reset <= '1';
    wait for 17 ns;
    cpu_reset <= '0';

    wait;
  end process;
end architecture;
