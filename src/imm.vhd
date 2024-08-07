library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_types.all;

entity imm is
  port (
    instr     : in  instruction;
    opcode    : in  uOP;
    immediate : out word
    );
end imm;

-- Architecture slicing of imm: slices immediate out of instruction
architecture slicing of imm is

begin
  -- Process immediate  slice
  process (opcode, instr)
  begin
    case opcode is
      -- I-Type
      when uLB | uLH | uLW | uLBU | uLHU | uADDI | uSLTI | uSLTIU | uXORI | uORI | uANDI => immediate <= std_logic_vector(to_unsigned(0, wordWidth - 12)) & instr(31 downto 20);

      -- S-Type
      when uSB | uSH | uSW => immediate <= std_logic_vector(to_unsigned(0, wordWidth-12)) & instr(31 downto 25) & instr(11 downto 7);

      -- B-Type
      when uBEQ | uBNE | uBLT | uBGE | uBLTU | uBGEU => immediate <= std_logic_vector(to_unsigned(0, 19)) & instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & "0";

      -- U-Type
      when uLUI | uAUIPC => immediate <= instr(31 downto 12) & std_logic_vector(to_unsigned(0, 12));

      -- J-Type
      when uJAL => immediate <= std_logic_vector(to_unsigned(0, wordWidth - 21)) & instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & "0";

      when others => immediate <= x"C000FFEE";
    end case;
  end process;

end slicing;

