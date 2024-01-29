library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_types.all;

library std;
use std.textio.all;

entity ram_tb is
end ram_tb;

architecture Behavioral of ram_tb is

  -- Clock
  signal clk : std_logic;

  -- Inputs
  signal addr_a       : std_logic_vector(ram_addr_size - 1 downto 0);
  signal write_b      : std_logic_vector(1-1 downto 0);
  signal addr_b       : std_logic_vector(ram_addr_size - 1 downto 0);
  signal data_write_b : std_logic_vector(wordWidth - 1 downto 0);

  -- Outputs
  signal data_read_a : std_logic_vector(wordWidth - 1 downto 0);
  signal data_read_b : std_logic_vector(wordWidth - 1 downto 0);

  -- Clock period definitions
  constant clk_period : time := 10 ns;

  -- Unittest Signale
  signal tb_addr_a   : integer;
  signal tb_addr_b   : integer;
  signal tb_test_v   : std_logic_vector(wordWidth - 1 downto 0);
  signal tb_check_v  : std_logic_vector(wordWidth - 1 downto 0);
  signal tb_validate : std_logic;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : entity work.ram(Behavioral)
    port map (clk            => clk,
              instructionAdr => addr_a,
              dataAdr        => addr_b,
              writeEnable    => write_b,
              dataIn         => data_write_b,
              instruction    => data_read_a,
              dataOut        => data_read_b);

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- Stimulus process
  stim_proc : process
    variable lineBuffer : line;
  begin

    wait for 5 ns;

    -- Wait for the first rising edge
    wait until rising_edge(clk);

    -- manual test
    addr_a  <= "001101001110";
    addr_b  <= "011100110010";
    write_b <= "1";

    wait for 10 ns;

    -- Testing Mem
    tb_validate <= '1';
    write_b     <= std_logic_vector(to_unsigned(1, 1));
    for test_case in 0 to 1000 loop
      for tb_addr in 0 to 4096 loop
        -- assign test values
        tb_test_v  <= std_logic_vector(to_unsigned(tb_addr, wordWidth));
        tb_check_v <= std_logic_vector(to_unsigned(tb_addr, wordWidth));

        -- Test this value
        addr_a       <= std_logic_vector(to_unsigned(tb_addr, ram_addr_size));
        addr_b       <= std_logic_vector(to_unsigned(tb_addr, ram_addr_size));
        data_write_b <= tb_test_v;

        if (data_read_a = tb_check_v and data_read_b = tb_check_v) then
          tb_validate <= '0';
          write(lineBuffer, string'("Everything fine!"));
          writeline(output, lineBuffer);
        else
          tb_validate <= '1';
        end if;
        wait for 10 ns;
      end loop;
    end loop;

    -- Simply wait forever
    wait;

  end process;
end architecture;
