-- riscv_types.vhd
-- Created on: So 13. Nov 19:05:44 CET 2022
-- Author(s): Carl Ries, Yannick Reiß, Alexander Graf
-- Content: All types needed in processor
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package riscv_types is

  -- internal opCodes/enums for instructions
  type uOP is (uNOP, uLUI, uAUIPC, uJAL, uJALR, uBEQ, uBNE, uBLT, uBGE, uBLTU, uBGEU,
               uLB, uLH, uLW, uLBU, uLHU, uSB, uSH, uSW, uADDI, uSLTI, uSLTIU,
               uXORI, uORI, uANDI, uSLLI, uSRLI, uSRAI, uADD, uSUB, uSLL, uSLT,
               uSLTU, uXOR, uSRL, uSRA, uOR, uAND, uECALL);

  -- internal opCodes/enums for alu instructions
  type aluOP is (uNOP, uADD, uSUB, uSLL, uSLT, uSLTU, uXOR, uSRL, uSRA, uOR, uAND);

  -- internal instruction formats
  type inst_formats is (R, I, S, B, U, J);

  -- internal immediat formats
  type imm_formats is (I, S, B, U, J);

  -- cpu states
  type cpuStates is (stIF, stDEC, stOF, stEXEC, stWB);

  -- internal opCodes/enums for memory operation
  type memOP is (uNOP, uLB, uLH, uLW, uLBU, uLHU, uSB, uSH, uSW);

  -- internal opCodes/enums for branching
  type branchOP is (uNOP, uEQ, uNE, uLT, uLTU, uGE, uGEU);

  -- Size of words
  constant wordWidth : integer := 32;

  -- bit vectors for different types
  subtype word is std_logic_vector(wordWidth - 1 downto 0);  -- 32bit (word)
  subtype half is std_logic_vector(16 - 1 downto 0);         -- 16bit (half)
  subtype byte is std_logic_vector(8 - 1 downto 0);          --  8bit (byte)
  subtype four_bit is std_logic_vector(4 - 1 downto 0);      --  4bit vector
  subtype two_bit is std_logic_vector(2 - 1 downto 0);       --  2bit vector
  subtype one_bit is std_logic_vector(1 - 1 downto 0);       --  1bit vector
  subtype instruction is std_logic_vector(wordWidth - 1 downto 0);  --  instruction
  subtype opcode is std_logic_vector(7 - 1 downto 0);        --  7bit opcode
  subtype reg_idx is std_logic_vector(5 - 1 downto 0);       -- register index
  subtype funct3 is std_logic_vector(3 - 1 downto 0);        -- 3bit sub opcode
  subtype shamt is std_logic_vector(5 - 1 downto 0);         -- shift amount
  subtype upper_imm is std_logic_vector(31 downto 12);       -- upper immediate
  subtype imm_12 is std_logic_vector(12 - 1 downto 0);       -- 12bit immediate


  -- constants for the 7bit opcode field in a normal 32bit instruction.
  -- for 32bit size instructions the last 2 bits always have to be '1' 
  -- xxxxx11
  constant opc_LUI    : opcode := "0110111";  -- load upper immediate
  constant opc_AUIPC  : opcode := "0010111";  -- add upper immediate to pc
  constant opc_JAL    : opcode := "1101111";  -- jump and link
  constant opc_JALR   : opcode := "1100111";  -- jump and link register
  constant opc_BRANCH : opcode := "1100011";  -- branch --
  constant opc_LOAD   : opcode := "0000011";  -- load --
  constant opc_STORE  : opcode := "0100011";  -- store --
  constant opc_ALUI   : opcode := "0010011";  -- alu immediate --
  constant opc_ALUR   : opcode := "0110011";  -- alu register --
  constant opc_FENCE  : opcode := "0001111";  -- fence
  constant opc_ECALL  : opcode := "1110011";  -- ecall
  constant opc_EBREAK : opcode := "1110011";  -- break
  constant opc_NULL   : opcode := "0000000";  -- invalid

  -- constant for alu double funct3 entrys. (e.g. SUB instruction)
  constant alu_flag : std_logic_vector(7 - 1 downto 0) := "0100000";

  -- constants for the funct3 field on branches
  constant branch_EQ  : funct3 := "000";
  constant branch_NE  : funct3 := "001";
  constant branch_LT  : funct3 := "100";
  constant branch_GE  : funct3 := "101";
  constant branch_LTU : funct3 := "110";
  constant branch_GEU : funct3 := "111";

  -- constants for the funct3 field on loads
  constant load_B   : funct3 := "000";  -- byte
  constant load_H   : funct3 := "001";  -- half
  constant load_W   : funct3 := "010";  -- word
  constant load_LBU : funct3 := "100";  -- byte unsigned
  constant load_LHU : funct3 := "101";  -- half unsigned

  -- constants for the funct3 field on stores
  constant store_B : funct3 := "000";   -- byte
  constant store_H : funct3 := "001";   -- half
  constant store_W : funct3 := "010";   -- word

  -- constants for the funct3 field for alu
  constant alu_ADD  : funct3 := "000";  -- add
  constant alu_SUB  : funct3 := "000";  -- sub also needs alu_flag set
  constant alu_SLT  : funct3 := "010";  -- set less than
  constant alu_SLTU : funct3 := "011";  -- set less than immediate
  constant alu_AND  : funct3 := "111";  -- and
  constant alu_OR   : funct3 := "110";  -- or
  constant alu_XOR  : funct3 := "100";  -- xor
  constant alu_SLL  : funct3 := "001";  -- shift left  logical
  constant alu_SRL  : funct3 := "101";  -- shift right logical
  constant alu_SRA  : funct3 := "101";  -- shift right arithmetic

-- regFile constants and type
  constant reg_adr_size : integer := 5;
  constant reg_size     : integer := 32;
  type regFile is array (reg_size - 1 downto 0) of word;

  -- ram constants and type
  constant ram_size       : natural := 4096;
  constant ram_block_size : natural := 1024;
  constant ram_addr_size  : natural := 12;

  subtype ram_addr_t is std_logic_vector(ram_addr_size -1 downto 0);
  -- type ram_t is array(0 to ram_addr_size - 1) of word;
  type ram_t is array(0 to 255) of word;

  -- const for multiplexer sources
  constant mul_wr_alures  : two_bit := "00";
  constant mul_wr_memread : two_bit := "01";
  constant mul_wr_pc4     : two_bit := "10";

  constant mul_alu_reg : one_bit := "0";

  constant mul_alu_pc  : one_bit := "1";
  constant mul_alu_imm : one_bit := "1";

  constant mul_pc_pc4 : one_bit := "0";
  constant mul_pc_alu : one_bit := "1";

end riscv_types;

package body riscv_types is
end riscv_types;
