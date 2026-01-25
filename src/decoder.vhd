-- decoder.vhd
-- Created on: Do 8. Dez 18:45:24 CET 2022
-- Author(s): Nina Chloé Kassandra Reiß <nina.reiss@nickr.eu>
-- Content: Decoder Version 2 (ständige vollbelegung)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

entity Decoder is
    port (
        Raw_Instruction     : in  instruction;
        Operation           : out uOP;
        Immediate_Structure : out imm_formats;
        Operand_Register_1  : out reg_idx;
        Operand_Register_2  : out reg_idx;
        Write_Register      : out reg_idx
    );
end entity Decoder;

-- Architecture schematic of decode: Split up instruction into registers
architecture Decode of Decoder is

begin

    -- Process decode  splits up instruction for alu
    process (Raw_Instruction(11 downto 7), Raw_Instruction(14 downto 12), Raw_Instruction(19 downto 15),
    Raw_Instruction(24 downto 20), Raw_Instruction(31 downto 25), Raw_Instruction(6 downto 0)) is -- runs only, when Raw_Instruction changed
    begin

        -- Operation (funct7 + funct3 + operand)
        case Raw_Instruction(6 downto 0) is
                -- R-Type
            when "0110011" =>
                case Raw_Instruction(14 downto 12) is
                    when "000" =>
                        if Raw_Instruction(31 downto 25) = "0000000" then
                            Operation <= uADD;
                        else
                            Operation <= uSUB;
                        end if;                                                                   -- ADD / SUB
                    when "001" =>
                        Operation     <= uSLL;
                    when "010" =>
                        Operation     <= uSLT;
                    when "011" =>
                        Operation     <= uSLTU;
                    when "100" =>
                        Operation     <= uXOR;
                    when "101" =>
                        if Raw_Instruction(31 downto 25) = "0000000" then
                            Operation <= uSRL;
                        else
                            Operation <= uSRA;
                        end if;
                    when "110" =>
                        Operation     <= uOR;
                    when "111" =>
                        Operation     <= uAND;
                    when others =>
                        Operation     <= uNOP;
                end case;

                -- I-Type
            when "1100111" =>
                Operation             <= uJALR;
            when "0000011" =>
                case Raw_Instruction(14 downto 12) is
                    when "000" =>
                        Operation     <= uLB;
                    when "001" =>
                        Operation     <= uLH;
                    when "010" =>
                        Operation     <= uLW;
                    when "100" =>
                        Operation     <= uLBU;
                    when "101" =>
                        Operation     <= uLHU;
                    when others =>
                        Operation     <= uNOP;
                end case;
            when "0010011" =>
                case Raw_Instruction(14 downto 12) is
                    when "000" =>
                        Operation     <= uADDI;
                    when "001" =>
                        Operation     <= uSLTI;
                    when "010" =>
                        Operation     <= uSLTIU;
                    when "011" =>
                        Operation     <= uXORI;
                    when "100" =>
                        Operation     <= uORI;
                    when "101" =>
                        Operation     <= uANDI;
                    when others =>
                        Operation     <= uNOP;
                end case;

                -- S-Type
            when "0100011" =>
                case Raw_Instruction(14 downto 12) is
                    when "000" =>
                        Operation     <= uSB;
                    when "001" =>
                        Operation     <= uSH;
                    when "010" =>
                        Operation     <= uSW;
                    when others =>
                        Operation     <= uNOP;
                end case;

                -- B-Type
            when "1100011" =>
                case Raw_Instruction(14 downto 12) is
                    when "000" =>
                        Operation     <= uBEQ;
                    when "001" =>
                        Operation     <= uBNE;
                    when "100" =>
                        Operation     <= uBLT;
                    when "101" =>
                        Operation     <= uBGE;
                    when "110" =>
                        Operation     <= uBLTU;
                    when "111" =>
                        Operation     <= uBGEU;
                    when others =>
                        Operation     <= uNOP;
                end case;

                -- U-Type
            when "0110111" =>
                Operation             <= uLUI;
            when "0010111" =>
                Operation             <= uAUIPC;

                -- J-Type
            when "1101111" =>
                Operation             <= uJAL;

                -- Add more Operandtypes here
            when others =>
                Operation             <= uNOP;
        end case;

        -- Operand_Register_1 (19-15)
        Operand_Register_1            <= Raw_Instruction(19 downto 15);

        -- Operand_Register_2 (24-20)
        Operand_Register_2            <= Raw_Instruction(24 downto 20);

        -- Write_Register (11-7)
        Write_Register                <= Raw_Instruction(11 downto 7);
    end process;

    with Raw_Instruction(6 downto 0) select
    Immediate_Structure <= I when "0000011" | "0010011" | "1100111" | "1110011" | "0000111" | "0001011" | "1011011",
                        S when "0100011" | "0100111" | "0101011" | "1111011",
                        B when "1100011",
                        U when "0110111" | "0010111",
                        J when "1101111",
                        None when others;
end architecture Decode;
