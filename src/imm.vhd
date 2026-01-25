library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

entity Immediate is
    port (
        Raw_Instruction   : in  instruction;
        Format_Structure  : in  imm_formats;
        Decoded_Immediate : out word
    );
end entity Immediate;


architecture slicing of Immediate is

begin

    process (Format_Structure, Raw_Instruction) is
    begin
        case Format_Structure is
            when I =>
                Decoded_Immediate <= std_logic_vector(to_unsigned(0, wordWidth - 12)) & Raw_Instruction(31 downto 20);
            when S =>
                Decoded_Immediate <=
                    std_logic_vector(to_unsigned(0, wordWidth - 12)) & Raw_Instruction(31 downto 25) &
                        Raw_Instruction(11 downto 7);
            when B =>
                Decoded_Immediate <=
                    std_logic_vector(to_unsigned(0, 19)) & Raw_Instruction(31) & Raw_Instruction(7) &
                        Raw_Instruction(30 downto 25) & Raw_Instruction(11 downto 8) & "0";
            when U =>
                Decoded_Immediate <= Raw_Instruction(31 downto 12) & std_logic_vector(to_unsigned(0, 12));
            when J =>
                Decoded_Immediate <=
                    std_logic_vector(to_unsigned(0, wordWidth - 21)) & Raw_Instruction(31) &
                        Raw_Instruction(19 downto 12) & Raw_Instruction(20) & Raw_Instruction(30 downto 21) & "0";
            when others =>
                Decoded_Immediate <= x"00000000";
        end case;
    end process;

end architecture slicing;
