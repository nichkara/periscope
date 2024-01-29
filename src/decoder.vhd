-- vsg_off
-- decoder_reloaded.vhd
-- Created on: Do 8. Dez 18:45:24 CET 2022
-- Author(s): Axel, Carsten und Jannis
-- Content: Decoder Version 2 (ständige vollbelegung)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_types.all;

-- Entity decode: Decoder currently supporting read operations
entity decoder is
  port(
    instrDecode : in  instruction;      -- Instruction from instruction memory
    op_code     : out uOP;              -- alu opcode
    regOp1      : out reg_idx;          -- Rj: first register to read
    regOp2      : out reg_idx;          -- Rk: second register to read
    regWrite    : out reg_idx           -- Ri: the register to write to
    );
end decoder;

-- Architecture schematic of decode: Split up instruction into registers
architecture decode of decoder is

begin

  -- Process decode  splits up instruction for alu
  process (instrDecode(11 downto 7), instrDecode(14 downto 12),
           instrDecode(19 downto 15), instrDecode(24 downto 20),
           instrDecode(31 downto 25), instrDecode(6 downto 0))  -- runs only, when instrDecode changed
  begin
    -- ONLY DECODES  RV32I Base Instruction Set
    -- op_code (funct7 + funct3 + operand)
    case instrDecode(6 downto 0) is
      -- R-Type
      when "0110011" =>
        case instrDecode(14 downto 12) is
          when "000" =>
            if instrDecode(31 downto 25) = "0000000" then
              op_code <= uADD;
            else
              op_code <= uSUB;
            end if;  -- ADD / SUB
          when "001" => op_code <= uSLL;
          when "010" => op_code <= uSLT;
          when "011" => op_code <= uSLTU;
          when "100" => op_code <= uXOR;
          when "101" =>
            if instrDecode(31 downto 25) = "0000000" then
              op_code <= uSRL;
            else
              op_code <= uSRA;
            end if;
          when "110"  => op_code <= uOR;
          when "111"  => op_code <= uAND;
          when others => op_code <= uNOP;
        end case;

      -- I-Type
      when "1100111" => op_code <= uJALR;
      when "0000011" =>
        case instrDecode(14 downto 12) is
          when "000"  => op_code <= uLB;
          when "001"  => op_code <= uLH;
          when "010"  => op_code <= uLW;
          when "100"  => op_code <= uLBU;
          when "101"  => op_code <= uLHU;
          when others => op_code <= uNOP;
        end case;
      when "0010011" =>
        case instrDecode(14 downto 12) is
          when "000"  => op_code <= uADDI;
          when "001"  => op_code <= uSLTI;
          when "010"  => op_code <= uSLTIU;
          when "011"  => op_code <= uXORI;
          when "100"  => op_code <= uORI;
          when "101"  => op_code <= uANDI;
          when others => op_code <= uNOP;
        end case;

      -- S-Type
      when "0100011" =>
        case instrDecode(14 downto 12) is
          when "000"  => op_code <= uSB;
          when "001"  => op_code <= uSH;
          when "010"  => op_code <= uSW;
          when others => op_code <= uNOP;
        end case;

      -- B-Type 
      when "1100011" =>
        case instrDecode(14 downto 12) is
          when "000"  => op_code <= uBEQ;
          when "001"  => op_code <= uBNE;
          when "100"  => op_code <= uBLT;
          when "101"  => op_code <= uBGE;
          when "110"  => op_code <= uBLTU;
          when "111"  => op_code <= uBGEU;
          when others => op_code <= uNOP;
        end case;

      -- U-Type
      when "0110111" => op_code <= uLUI;
      when "0010111" => op_code <= uAUIPC;

      -- J-Type
      when "1101111" => op_code <= uJAL;

      -- Add more Operandtypes here
      when others => op_code <= uNOP;
    end case;

    -- regOp1 (19-15)
    regOp1 <= instrDecode(19 downto 15);

    -- regOp2 (24-20)
    regOp2 <= instrDecode(24 downto 20);

    -- regWrite (11-7)
    regWrite <= instrDecode(11 downto 7);
  end process;
end decode;
