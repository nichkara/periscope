library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

library std;
use std.textio.all;
use std.env.finish;

entity Memory_Testbench is
end entity Memory_Testbench;

architecture Behavioral of Memory_Testbench is

    -- Clock
    signal Clock_Sim             : std_logic                                    := '0';

    -- Inputs
    signal Address_A             : std_logic_vector(ram_addr_size - 1 downto 0) := (others => '0');
    signal Memory_Write_Enable   : std_logic                                    := '0';
    signal Address_B             : std_logic_vector(ram_addr_size - 1 downto 0) := (others => '0');
    signal Memory_Write          : std_logic_vector(wordWidth - 1 downto 0)     := (others => '0');

    -- Outputs
    signal Memory_Read_A         : std_logic_vector(wordWidth - 1 downto 0)     := (others => '0');
    signal Memory_Read_B         : std_logic_vector(wordWidth - 1 downto 0)     := (others => '0');

    -- Clock period definitions
    constant Clock_Sim_Period    : time                                         := 10 ns;
    constant Test_Cases          : natural                                      := 4096;

    -- Unittest Signale
    signal Validation            : std_logic                                    := '0';
    signal Left_Value_Debug_Flag : std_logic_vector(ram_addr_size - 1 downto 0);
    signal Neg_Reset             : std_logic                                    := '1';

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.Memory(Simulation)
    port map (
        Clock                   => Clock_Sim,
        Reset_N                 => Neg_Reset,
        Instruction_Address     => Address_A,
        Data_Address            => Address_B,
        Enable_Memory_Writeback => Memory_Write_Enable,
        Write_Data              => Memory_Write,
        Read_Instruction        => Memory_Read_A,
        Read_Data               => Memory_Read_B
    );

    -- Clock process definitions
    Clock_Sim_Process: process
    begin
        Clock_Sim                 <= '0';
        wait for Clock_Sim_Period / 2;
        Clock_Sim                 <= '1';
        wait for Clock_Sim_Period / 2;
    end process Clock_Sim_Process;

    Read_Write_Test: process
    begin

        wait for 5 ns;

        -- Wait for the first rising edge
        wait until rising_edge(Clock_Sim);
        Neg_Reset                 <= '1';
        wait for 5 ns;
        Neg_Reset                 <= '0';
        wait for 10 ns;
        Neg_Reset                 <= '1';

        -- Testing Mem
        Validation                <= '0';
        Memory_Write_Enable       <= '1';
        for Test_Address in 2048 to Test_Cases + 2048 loop
            -- assign test values
            Address_B             <= std_logic_vector(to_unsigned(Test_Address, 30)) & "00";
            Memory_Write          <= std_logic_vector(to_unsigned(Test_Address, 30)) & "00";
            wait for 10 ns;
        end loop;
        Memory_Write_Enable       <= '0';
        wait until rising_edge(Clock_Sim);

        for Test_Address in 2048 to Test_Cases + 2048 loop
            -- test port a
            Address_B             <= std_logic_vector(to_unsigned(Test_Address, 30)) & "00";
            Left_Value_Debug_Flag <= std_logic_vector(to_unsigned(Test_Address, 30)) & "00";
            wait until rising_edge(Clock_Sim);
            if unsigned(Left_Value_Debug_Flag) = unsigned(Memory_Read_B) then
                Validation        <= Validation or '0';
            else
                Validation        <= '1';
            end if;
            wait until rising_edge(Clock_Sim);
        end loop;
        if Validation = '1' then
            assert false report "Validation error on port b." severity failure;
        end if;
        finish;

    end process Read_Write_Test;
end architecture Behavioral;
