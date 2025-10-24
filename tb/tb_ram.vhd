library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

library std;
use std.textio.all;
use std.env.finish;

entity ram_tb is
end entity ram_tb;

architecture Behavioral of ram_tb is

    -- Clock
    signal clk          : std_logic                                    := '0';

    -- Inputs
    signal addr_a       : std_logic_vector(ram_addr_size - 1 downto 0) := (others => '0');
    signal write_b      : std_logic                                    := '0';
    signal addr_b       : std_logic_vector(ram_addr_size - 1 downto 0) := (others => '0');
    signal data_write_b : std_logic_vector(wordWidth - 1 downto 0)     := (others => '0');

    -- Outputs
    signal data_read_a  : std_logic_vector(wordWidth - 1 downto 0)     := (others => '0');
    signal data_read_b  : std_logic_vector(wordWidth - 1 downto 0)     := (others => '0');

    -- Clock period definitions
    constant clk_period : time                                         := 10 ns;
    constant test_cases : natural                                      := 16384;

    -- Unittest Signale
    signal tb_validate  : std_logic                                    := '0';
    signal s_dbg_left   : std_logic_vector(ram_addr_size - 1 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.ram(Behavioral)
    port map (
        clk             => clk,
        instructionAddr => addr_a,
        dataAddr        => addr_b,
        writeEnable     => write_b,
        dataIn          => data_write_b,
        instruction     => data_read_a,
        dataOut         => data_read_b
    );

    -- Clock process definitions
    clk_process: process
    begin
        clk                 <= '0';
        wait for clk_period / 2;
        clk                 <= '1';
        wait for clk_period / 2;
    end process clk_process;

    -- Stimulus process
    stim_proc: process
    begin

        wait for 5 ns;

        -- Wait for the first rising edge
        wait until rising_edge(clk);

        -- Testing Mem
        tb_validate         <= '0';
        write_b             <= '1';
        for tb_addr in 0 to test_cases loop
            -- assign test values
            addr_b          <= "1" & std_logic_vector(to_unsigned(tb_addr, 29)) & "00";
            data_write_b    <= std_logic_vector(to_unsigned(tb_addr, 32)) and x"fffffffc";
            wait for 10 ns;
        end loop;
        write_b             <= '0';

        for tb_addr in 0 to test_cases loop
            -- test port a
            addr_b          <= "1" & std_logic_vector(to_unsigned(tb_addr, 29)) & "00";
            wait for 10 ns;
            s_dbg_left      <= std_logic_vector(to_unsigned(tb_addr, 32)) and x"fffffffc";
            if (std_logic_vector(to_unsigned(tb_addr, 32)) and x"fffffffc") = data_read_b then
            else
                tb_validate <= '1';
            end if;
        end loop;
        if tb_validate = '1' then
            assert false report "Validation error on port b." severity failure;
        end if;
        finish;

    end process stim_proc;
end architecture Behavioral;
