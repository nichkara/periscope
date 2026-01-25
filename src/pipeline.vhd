-- pipeline.vhd
-- Created on: Mon 05 Jan 2026 18:07:19 CET
-- Author(s): Nina Chloé Reiß
-- Content: Pipeline entity controlling and storing cpu state.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

entity Pipeline is
    port (
        Clock                     : in  std_logic;
        Reset_N                   : in  std_logic;
        Instruction               : in  word;
        Register_Id_X             : in  reg_idx;
        Register_A                : in  word;
        Register_B                : in  word;
        Immediate                 : in  word;
        Instruction_Address       : in  word;
        Enable_Program_Counter    : out std_logic;
        Enable_Register_Writeback : out std_logic;
        Enable_Memory_Writeback   : out std_logic
    );
end entity Pipeline;

-- Architecture Simple of Pipeline: No forwarding, branch prediction, etc.
architecture Simple of Pipeline is
    signal Target_Registers                 : word;
    signal Register_X_Serial                : word;
    signal Drop_Register                    : word;
    signal Instructions_In_Pipeline         : std_logic_vector(2 downto 0);
    signal Clear_Pipeline                   : std_logic;

    -- Skip execution state buffer
    signal Operand_Fetch_Opcode             : opcode;
    signal Operand_Fetch_Result_Destination : Destination;
    signal Execute_Result_Destination       : Destination;
begin

    -- Expand Register X
    with Register_Id_X select
    Register_X_Serial <=
                x"00000001" when "00000",
                x"00000002" when "00001",
                x"00000004" when "00010",
                x"00000008" when "00011",
                x"00000010" when "00100",
                x"00000020" when "00101",
                x"00000040" when "00110",
                x"00000080" when "00111",
                x"00000100" when "01000",
                x"00000200" when "01001",
                x"00000400" when "01010",
                x"00000800" when "01011",
                x"00001000" when "01100",
                x"00002000" when "01101",
                x"00004000" when "01110",
                x"00008000" when "01111",
                x"00010000" when "10000",
                x"00020000" when "10001",
                x"00040000" when "10010",
                x"00080000" when "10011",
                x"00100000" when "10100",
                x"00200000" when "10101",
                x"00400000" when "10110",
                x"00800000" when "10111",
                x"01000000" when "11000",
                x"02000000" when "11001",
                x"04000000" when "11010",
                x"08000000" when "11011",
                x"10000000" when "11100",
                x"20000000" when "11101",
                x"40000000" when "11110",
                x"80000000" when "11111",
                x"00000000" when others;

    Pipeline_Clear_Check: process (Clock, Reset_N, Register_X_Serial) is -- runs only, when Clock, Reset_N, Register_Id_X changed
    begin

        if rising_edge(Clock) then
            if Reset_N = '0' then
                Clear_Pipeline                   <= '1';
                Target_Registers                 <= (others => '0');
                Instructions_In_Pipeline         <= "111";
            else
                if (Target_Registers and Register_X_Serial) = x"0" then
                    Target_Registers             <= Target_Registers or Register_X_Serial;
                    if Instructions_In_Pipeline = "000" then
                        Clear_Pipeline           <= '0';
                    end if;
                else
                    Clear_Pipeline               <= '1';
                end if;

                if Clear_Pipeline = '1' then
                    if Instructions_In_Pipeline = "000" then
                        Instructions_In_Pipeline <= "000";
                    else
                        Instructions_In_Pipeline <= std_logic_vector(unsigned(Instructions_In_Pipeline) - 1);
                    end if;
                else
                    if Instructions_In_Pipeline = "101" then
                        Instructions_In_Pipeline <= "101";
                    else
                        Instructions_In_Pipeline <= std_logic_vector(unsigned(Instructions_In_Pipeline) + 1);
                    end if;

                end if;
            end if;
        end if;

    end process Pipeline_Clear_Check;

    -- Decode

    -- Operand fetch

    -- Execute

    -- Write back

end architecture Simple;
