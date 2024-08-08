-- cpu.vhd
-- Created on: Mo 19. Dez 11:07:17 CET 2022
-- Author(s): Yannick Reiss
-- Content:  Entity cpu
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_types.all;

-- Entity cpu: path implementation of RISC-V cpu
entity cpu is
  port(
    clk                 : in  std_logic;  -- clk to control the unit
    rst                 : in  std_logic;
    instruction_read    : in  word;
    ram_read_data       : in  word;
    ram_enable_writing  : out std_logic;
    instruction_pointer : out ram_addr_t;
    data_address        : out ram_addr_t;
    ram_write_data      : out word
    );
end cpu;

-- Architecture implementation of c: control and connect different parts of cpu
architecture implementation of cpu is

  component pc
    port(
      clk       : in  std_logic;        -- Clock input for timing
      reset     : in  std_logic;
      en_pc     : in  one_bit;          -- activates PC
      addr_calc : in  ram_addr_t;       -- Address from ALU
      doJump    : in  one_bit;          -- Jump to Address
      addr      : out ram_addr_t        -- Address to Decoder
      );
  end component;

  component alu
    port (
      alu_opc : in  aluOP;              -- alu opcode.
      input1  : in  word;   -- input1 of alu (reg1 / pc address) rs1
      input2  : in  word;   -- input2 of alu (reg2 / immediate)  rs2
      result  : out word                -- alu output.
      );
  end component;

  component decoder
    port(
      instrDecode : in  instruction;    -- Instruction from instruction memory
      op_code     : out uOP;            -- alu opcode
      regOp1      : out reg_idx;        -- Rj: first register to read
      regOp2      : out reg_idx;        -- Rk: second register to read
      regWrite    : out reg_idx         -- Ri: the register to write to
      );
  end component;

  component imm
    port (
      instr     : in  instruction;
      opcode    : in  uOP;
      immediate : out word
      );
  end component;

  component registers
    port(
      clk          : in  std_logic;     -- input for clock (control device)
      reset        : in  std_logic;
      en_reg_wb    : in  one_bit;       -- enable register write back (?)
      data_in      : in  word;          -- Data to be written into the register
      wr_idx       : in  reg_idx;       -- register to write to
      r1_idx       : in  reg_idx;       -- first register to read from
      r2_idx       : in  reg_idx;       -- second register to read from
      write_enable : in  one_bit;       -- enable writing to wr_idx
      r1_out       : out word;          -- data from first register
      r2_out       : out word           -- data from second register
      );
  end component;

  component Branch
    port(
      op_code    : in  uOP;
      reg1       : in  word;
      reg2       : in  word;
      jmp_enable : out one_bit
      );
  end component;

  -- SIGNALS GLOBAL
  signal s_clock          : std_logic := '0';
  signal s_reg_wb_enable  : one_bit   := "0";  --enables: register writeback
  signal s_reg_wr_enable  : one_bit   := "0";  --enables: register write to index
  signal s_pc_enable      : one_bit   := "0";  --enables: pc
  signal s_pc_jump_enable : one_bit   := "0";  --enables: pc jump to address
  signal s_ram_enable     : std_logic := '0';  --enables: ram write enalbe

  -- decoder -> registers
  signal s_idx_1  : reg_idx;
  signal s_idx_2  : reg_idx;
  signal s_idx_wr : reg_idx;

  -- decoder -> imm ( + decoder)
  signal s_opcode : uOP;

  -- register -> alu
  signal s_reg_data1 : word;
  signal s_reg_data2 : word;

  -- pc -> ram
  signal s_instAddr           : ram_addr_t;
  signal s_cycle_cnt          : cpuStates := stIF;
  signal s_branch_jump_enable : one_bit;

  -- alu -> ram + register
  signal s_alu_data : word;

  -- ram -> register
  signal s_ram_data : word;

  --ram -> decoder + imm
  signal s_inst         : instruction;
  signal s_data_in_addr : ram_addr_t;

  --  v  dummy signals below  v

  --imm -> ???
  signal s_immediate : word;

  -- ???   -> alu
  signal X_aluOP : aluOP;

  -- ???   -> alu
  signal X_addr_calc : ram_addr_t;

  -- Clock signals
  signal reset  : std_logic := '0';
  signal locked : std_logic := '0';

-------------------------
-- additional ALU signals
-------------------------
  signal aluIn1 : word;
  signal aluIn2 : word;

-------------------------
-- additional REG signals
-------------------------
  signal reg_data_in : word;

begin

  -- External assignments
  s_clock             <= clk;
  reset               <= rst;
  ram_enable_writing  <= s_ram_enable;
  instruction_pointer <= s_instAddr;
  data_address        <= s_data_in_addr;
  ram_write_data      <= s_alu_data;
  s_inst              <= instruction_read;
  s_ram_data          <= ram_read_data;

  decoder_RISCV : decoder
    port map(
      instrDecode => s_inst,
      op_code     => s_opcode,
      regOp1      => s_idx_1,
      regOp2      => s_idx_2,
      regWrite    => s_idx_wr
      );

  registers_RISCV : registers
    port map(
      clk          => s_clock,
      reset        => reset,
      en_reg_wb    => s_reg_wb_enable,
      data_in      => reg_data_in,
      wr_idx       => s_idx_wr,
      r1_idx       => s_idx_1,
      r2_idx       => s_idx_2,
      write_enable => s_reg_wr_enable,
      r1_out       => s_reg_data1,
      r2_out       => s_reg_data2
      );

  imm_RISCV : imm
    port map(
      instr     => s_inst,
      opcode    => s_opcode,
      immediate => s_immediate
      );

  pc_RISCV : pc
    port map(
      clk       => s_clock,
      reset     => reset,
      en_pc     => s_pc_enable,
      addr_calc => X_addr_calc,
      doJump    => s_pc_jump_enable,
      addr      => s_instAddr
      );

  alu_RISCV : alu
    port map(
      alu_opc => X_aluOP,               -- switch case from s_opcode
      input1  => aluIn1,
      input2  => aluIn2,
      result  => s_alu_data
      );

  branch_RISCV : Branch
    port map(
      op_code    => s_opcode,
      reg1       => aluIn1,
      reg2       => aluIn2,
      jmp_enable => s_branch_jump_enable
      );

------------------------
-- ALU opcode and input connection
------------------------
  -- Process alu_control  set alu opcode

  -----------------------------------------
  -- Output
  -----------------------------------------

  alu_control : process (s_immediate, s_opcode, s_reg_data1, s_reg_data2)  -- runs only, when item in list changed
  begin
                                        -- Connect opcode
    case s_opcode is
      when uADD | uADDI   => X_aluOP <= uADD;
      when uSUB           => X_aluOP <= uSUB;
      when uSLL | uSLLI   => X_aluOP <= uSLL;
      when uSLT | uSLTI   => X_aluOP <= uSLT;
      when uSLTU | uSLTIU => X_aluOP <= uSLTU;
      when uXOR | uXORI   => X_aluOP <= uXOR;
      when uSRL | uSRLI   => X_aluOP <= uSRL;
      when uSRA | uSRAI   => X_aluOP <= uSRA;
      when uOR | uORI     => X_aluOP <= uOR;
      when uAND | uANDI   => X_aluOP <= uAND;
      when others         => X_aluOP <= uNOP;
    end case;
                                        -- connect input1
    case s_opcode is
      -- add nonstandard inputs for aluIn1 here
      when others => aluIn1 <= s_reg_data1;
    end case;

    -- connect input 2
    case s_opcode is
      when uADDI | uSLTI | uSLTIU | uXORI | uORI | uANDI => aluIn2 <= s_immediate;
      when others                                        => aluIn2 <= s_reg_data2;  -- use rs2 as default
    end case;
  end process;

  -- Process register_data_input  select which input is needed for register
  register_data_input : process (s_cycle_cnt, s_opcode, s_ram_data, s_alu_data)  -- runs only, when item in list changed
  begin
    s_reg_wb_enable <= "0";
    case s_opcode is
      when uBEQ | uBNE | uBLT | uBGE | uBLTU | uBGEU | uSB | uSH | uSW | uECALL | uNOP => s_reg_wr_enable <= "0";
      when others =>
        if s_cycle_cnt = stEXEC then
          s_reg_wr_enable <= "1";
        else
          s_reg_wr_enable <= "0";
        end if;
    end case;

    case s_opcode is
      when uLB | uLH | uLW | uLBU | uLHU => reg_data_in <= s_ram_data;  -- use value from
                                        -- RAM (Load instructions)
      when others                        => reg_data_in <= s_alu_data;  -- alu operations as default
    end case;
  end process;

  -- Process pc input
  pc_addr_input : process(s_opcode, s_cycle_cnt, s_instAddr, s_immediate)
  begin
    if s_cycle_cnt = stWB then
      s_pc_enable <= "1";
    else
      s_pc_enable <= "0";
    -- X_addr_calc <= s_instAddr; -- should not be necessary, every case option sets X_addr_calc
    end if;
    case s_opcode is
      when uJALR | uJAL =>
        s_pc_jump_enable <= "1";
        X_addr_calc      <= std_logic_vector(signed(s_immediate(11 downto 0)) + signed(s_instAddr));

      -- Branch op_codes
      when uBEQ | uBNE | uBLT | uBGE | uBLTU | uBGEU =>
        -- always load address from immediate on B-Type
        X_addr_calc      <= std_logic_vector(signed(s_immediate(11 downto 0)) + signed(s_instAddr));
        -- check for opcodes and evaluate condition
        s_pc_jump_enable <= s_branch_jump_enable;
      when others =>
        s_pc_jump_enable <= "0";
        X_addr_calc      <= s_instAddr;
    end case;
  end process;

  -- process ram
  ram_input : process(s_opcode, s_cycle_cnt)
  begin
    s_data_in_addr <= std_logic_vector(signed(s_immediate) + signed(s_reg_data1));
    if s_cycle_cnt = stWB then
      case s_opcode is
        when uSB | uSH | uSW => s_ram_enable <= '1';
        when others          => s_ram_enable <= '0';
      end case;
    else
      s_ram_enable <= '0';
    end if;
  end process;

  -- pc cycle control
  pc_cycle_control : process(s_clock, reset)
  begin
    if rising_edge(s_clock) then
      case s_cycle_cnt is
        when stIF   => s_cycle_cnt <= stDEC;
        when stDEC  => s_cycle_cnt <= stOF;
        when stOF   => s_cycle_cnt <= stEXEC;
        when stEXEC => s_cycle_cnt <= stWB;
        when others => s_cycle_cnt <= stIF;
      end case;
    end if;
    if falling_edge(reset) then
      s_cycle_cnt <= stIF;
    end if;
  end process pc_cycle_control;

end implementation;
