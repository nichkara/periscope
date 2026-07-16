-- tb_reg.vhd
-- Created on: Mo 14. Nov 11:55:58 CET 2022
-- Author(s): Nina Chlóe Kassandra Reiß <nina.reiss@nickr.eu>
-- Content: Testbench for the registerblock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.uniform;

use work.riscv_types.all;

library std;
use std.textio.all;
use std.env.finish;

-- Entity Register_Cluster_Testbench: Entity providing testinputs, receiving testoutputs for registerbench
entity Register_Cluster_Testbench is
end entity Register_Cluster_Testbench;

-- Architecture testing of Register_Cluster_Testbench: testing read / write operations
architecture Testing of Register_Cluster_Testbench is
    -- clock definition
    signal clk              : std_logic;
    constant clk_period     : time := 10 ns;

    -- Inputs
    signal data_in_tb       : word;
    signal wr_idx_tb        : reg_idx;
    signal r1_idx_tb        : reg_idx;
    signal r2_idx_tb        : reg_idx;
    signal write_enable_tb  : std_logic;

    -- Outputs
    signal r1_out_tb        : word;
    signal r2_out_tb        : word;

    signal Reset_N          : std_logic;

begin

    -- Init of Unit Under Test
    uut: entity work.Register_Cluster(Structure)
    port map (
        Clock              => clk,
        Reset_N            => Reset_N,
        Write_Data         => data_in_tb,
        Register_ID_Write  => wr_idx_tb,
        Register_ID_Read_1 => r1_idx_tb,
        Register_ID_Read_2 => r2_idx_tb,
        Enable_Writeback   => write_enable_tb,
        Read_Data_1        => r1_out_tb,
        Read_Data_2        => r2_out_tb
    );

    -- Process clk_process  operating the clock
    clk_process: process -- runs always
    begin
        clk                 <= '0';
        wait for clk_period / 2;
        clk                 <= '1';
        wait for clk_period / 2;
    end process clk_process;

    -- Stimulating the UUT
    -- Process stim_proc  control device for
    stim_proc: process
        -- Text I/O
        variable lineBuffer : line;

    begin

        -- wait for the rising edge
        wait until rising_edge(clk);
        Reset_N             <= '1';

        wait for 5 ns;
        Reset_N             <= '0';

        wait until rising_edge(clk);
        Reset_N             <= '1';

        -- Set up initial registers
        write_enable_tb     <= '1';
        wr_idx_tb           <= std_logic_vector(to_unsigned(0, reg_adr_size));
        data_in_tb          <= std_logic_vector(to_unsigned(1, wordWidth));
        wait for 10 ns;
        wr_idx_tb           <= std_logic_vector(to_unsigned(1, reg_adr_size));
        data_in_tb          <= std_logic_vector(to_unsigned(1, wordWidth));

        wait for 10 ns;
        write_enable_tb     <= '0';

        -- Check zero register first
        r1_idx_tb           <= std_logic_vector(to_unsigned(0, reg_adr_size));
        wait for 10 ns;
        assert r1_out_tb = std_logic_vector(to_unsigned(0, wordWidth))
            report "Zero register was set to a non zero value." severity failure;
        wait for 10 ns;

        for reg_z_addr in 2 to 31 loop
            wr_idx_tb       <= std_logic_vector(to_unsigned(reg_z_addr, reg_adr_size));
            r1_idx_tb       <= std_logic_vector(to_unsigned(reg_z_addr - 2, reg_adr_size));
            r2_idx_tb       <= std_logic_vector(to_unsigned(reg_z_addr - 1, reg_adr_size));
            wait for 10 ns;
            data_in_tb      <= std_logic_vector(unsigned(r1_out_tb) + unsigned(r2_out_tb));
            write_enable_tb <= '1';
            wait for 10 ns;
            write_enable_tb <= '0';
        end loop;

        -- Check register 31
        r1_idx_tb           <= std_logic_vector(to_unsigned(31, reg_adr_size));
        wait for 10 ns;
        assert r1_out_tb = std_logic_vector(to_unsigned(1346269, 32))
            report "Error: Final register has wrong assignment!" severity failure;

        -- end simulation
        write(lineBuffer, string'("Ending the simulation."));
        writeline(output, lineBuffer);
        finish;

    end process stim_proc;

end architecture Testing;
