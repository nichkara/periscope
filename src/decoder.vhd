-- decoder.vhd
-- Created on: Do 8. Dez 18:45:24 CET 2022
-- Author(s): Nina Chlóe Kassandra Reiß <nina.reiss@nickr.eu>
-- Content: Decoder Version 2 (ständige vollbelegung)

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.riscv_types.all;

entity decoder is
  port (
    raw_instruction     : in    instruction;
    operation           : out   uop;
    immediate_structure : out   imm_formats;
    operand_register_1  : out   reg_idx;
    operand_register_2  : out   reg_idx;
    write_register      : out   reg_idx
  );
end entity decoder;

-- Architecture schematic of decode: Split up instruction into registers

architecture decode of decoder is

begin

  -- Process decode  splits up instruction for alu
  process (raw_instruction(11 downto 7), raw_instruction(14 downto 12), raw_instruction(19 downto 15),
           raw_instruction(24 downto 20), raw_instruction(31 downto 25), raw_instruction(6 downto 0)) is -- runs only, when Raw_Instruction changed
  begin

    -- Operation (funct7 + funct3 + operand)
    case raw_instruction(6 downto 0) is

      -- R-Type
      when "0110011" =>

        case raw_instruction(14 downto 12) is

          when "000" =>

            if (raw_instruction(31 downto 25) = "0000000") then
              operation <= uADD;
            else
              operation <= uSUB;
            end if;                                                                   -- ADD / SUB

          when "001" =>

            operation <= uSLL;

          when "010" =>

            operation <= uSLT;

          when "011" =>

            operation <= uSLTU;

          when "100" =>

            operation <= uXOR;

          when "101" =>

            if (raw_instruction(31 downto 25) = "0000000") then
              operation <= uSRL;
            else
              operation <= uSRA;
            end if;

          when "110" =>

            operation <= uOR;

          when "111" =>

            operation <= uAND;

          when others =>

            operation <= uNOP;

        end case;

      -- I-Type
      when "1100111" =>

        operation <= uJALR;

      when "0000011" =>

        case raw_instruction(14 downto 12) is

          when "000" =>

            operation <= uLB;

          when "001" =>

            operation <= uLH;

          when "010" =>

            operation <= uLW;

          when "100" =>

            operation <= uLBU;

          when "101" =>

            operation <= uLHU;

          when others =>

            operation <= uNOP;

        end case;

      when "0010011" =>

        case raw_instruction(14 downto 12) is

          when "000" =>

            operation <= uADDI;

          when "001" =>

            operation <= uSLTI;

          when "010" =>

            operation <= uSLTIU;

          when "011" =>

            operation <= uXORI;

          when "100" =>

            operation <= uORI;

          when "101" =>

            operation <= uANDI;

          when others =>

            operation <= uNOP;

        end case;

      -- S-Type
      when "0100011" =>

        case raw_instruction(14 downto 12) is

          when "000" =>

            operation <= uSB;

          when "001" =>

            operation <= uSH;

          when "010" =>

            operation <= uSW;

          when others =>

            operation <= uNOP;

        end case;

      -- B-Type
      when "1100011" =>

        case raw_instruction(14 downto 12) is

          when "000" =>

            operation <= uBEQ;

          when "001" =>

            operation <= uBNE;

          when "100" =>

            operation <= uBLT;

          when "101" =>

            operation <= uBGE;

          when "110" =>

            operation <= uBLTU;

          when "111" =>

            operation <= uBGEU;

          when others =>

            operation <= uNOP;

        end case;

      -- U-Type
      when "0110111" =>

        operation <= uLUI;

      when "0010111" =>

        operation <= uAUIPC;

      -- J-Type
      when "1101111" =>

        operation <= uJAL;

      -- Add more Operandtypes here
      when others =>

        operation <= uNOP;

    end case;

    -- Operand_Register_1 (19-15)
    operand_register_1 <= raw_instruction(19 downto 15);

    -- Operand_Register_2 (24-20)
    operand_register_2 <= raw_instruction(24 downto 20);

    -- Write_Register (11-7)
    write_register <= raw_instruction(11 downto 7);

  end process;

  with Raw_Instruction(6 downto 0) select Immediate_Structure <=
    I when "0000011" | "0010011" | "1100111" | "1110011" | "0000111" | "0001011" | "1011011",
    S when "0100011" | "0100111" | "0101011" | "1111011",
    B when "1100011",
    U when "0110111" | "0010111",
    J when "1101111",
    None when others;

end architecture decode;
