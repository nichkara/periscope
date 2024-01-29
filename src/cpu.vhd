-- cpu.vhd
-- Created on: Mo 19. Dez 11:07:17 CET 2022
-- Author(s): Yannick Reiß, Carl Ries, Alexander Graf
-- Content:  Entity cpu
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_types.all;

-- Entity cpu: path implementation of RISC-V cpu
entity cpu is
  port(
    clk : in std_logic;                 -- clk to control the unit

    -- Led Output
    led : out std_logic_vector(15 downto 0);  -- output to 16 LEDS

    -- RGB Output
    RGB1 : out std_logic_vector(2 downto 0);  -- output to RGB 1
    RGB2 : out std_logic_vector(2 downto 0)   -- output to RGB 2
    );
end cpu;

-- Architecture implementation of c: control and connect different parts of cpu
architecture implementation of cpu is

  component pc
    port(
      clk       : in  std_logic;        -- Clock input for timing
      en_pc     : in  one_bit;          -- activates PC
      addr_calc : in  ram_addr_t;       -- Address from ALU
      doJump    : in  one_bit;          -- Jump to Address
      addr      : out ram_addr_t        -- Address to Decoder
      );
  end component;

  component ram
    port(
      clk            : in  std_logic;   -- Clock input for timing
      instructionAdr : in  ram_addr_t;  -- Address instruction
      dataAdr        : in  ram_addr_t;  -- Address data
      writeEnable    : in  one_bit;     -- Read or write mode
      dataIn         : in  word;        -- Write data
      instruction    : out word;        -- Get instruction
      dataOut        : out word         -- Read data
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
      instruction : in  instruction;
      opcode      : in  uOP;
      immediate   : out word
      );
  end component;

  component registers
    port(
      clk          : in  std_logic;     -- input for clock (control device)
      en_reg_wb    : in  one_bit;       -- enable register write back (?)
      data_in      : in  word;          -- Data to be written into the register
      wr_idx       : in  reg_idx;       -- register to write to
      r1_idx       : in  reg_idx;       -- first register to read from
      r2_idx       : in  reg_idx;       -- second register to read from
      write_enable : in  one_bit;       -- enable writing to wr_idx
      r1_out       : out word;          -- data from first register
      r2_out       : out word;          -- data from second register
      led_out      : out word           -- output led
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
  signal s_clock          : std_logic;
  signal s_reg_wb_enable  : one_bit;    --enables: register writeback
  signal s_reg_wr_enable  : one_bit;    --enables: register write to index
  signal s_pc_enable      : one_bit;    --enables: pc 
  signal s_pc_jump_enable : one_bit;    --enables: pc jump to address
  signal s_ram_enable     : one_bit;    --enables: ram write enalbe
  signal s_led_out        : word := "10110011100001110111010110101110";  -- stores the exact output



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
  signal s_instAdr            : ram_addr_t;
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
  signal reset : std_logic;
  signal locked : std_logic;

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

  s_clock <= clk;

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
      en_reg_wb    => s_reg_wb_enable,
      data_in      => reg_data_in,
      wr_idx       => s_idx_wr,
      r1_idx       => s_idx_1,
      r2_idx       => s_idx_2,
      write_enable => s_reg_wr_enable,
      r1_out       => s_reg_data1,
      r2_out       => s_reg_data2,
      led_out      => s_led_out
      );

  imm_RISCV : imm
    port map(
      instruction => s_inst,
      opcode      => s_opcode,
      immediate   => s_immediate
      );

  pc_RISCV : pc
    port map(
      clk       => s_clock,
      en_pc     => s_pc_enable,
      addr_calc => X_addr_calc,
      doJump    => s_pc_jump_enable,
      addr      => s_instAdr
      );

  alu_RISCV : alu
    port map(
      alu_opc => X_aluOP,               -- switch case from s_opcode
      input1  => aluIn1,
      input2  => aluIn2,
      result  => s_alu_data
      );

  ram_RISCV : ram
    port map(
      clk            => s_clock,         -- 
      instructionAdr => s_instAdr,       -- instruction from pc
      dataAdr        => s_data_in_addr,  -- data address from alu
      writeEnable    => s_ram_enable,    --
      dataIn         => s_reg_data2,     -- data from register
      instruction    => s_inst,          --
      dataOut        => s_ram_data
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
  led  <= s_led_out(15 downto 0);
  RGB1 <= s_clock & s_clock & s_clock;

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

    -- TODO: why line from pc to alu inp1?
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
  pc_addr_input : process(s_opcode, s_cycle_cnt, s_instAdr, s_immediate)
  begin
    if s_cycle_cnt = stWB then
      s_pc_enable <= "1";
    else
      s_pc_enable <= "0";
    -- X_addr_calc <= s_instAdr; -- should not be necessary, every case option sets X_addr_calc
    end if;
    case s_opcode is
      when uJALR | uJAL =>
        s_pc_jump_enable <= "1";
        X_addr_calc      <= std_logic_vector(signed(s_immediate(11 downto 0)) + signed(s_instAdr));

      -- Branch op_codes
      when uBEQ | uBNE | uBLT | uBGE | uBLTU | uBGEU =>
        -- always load address from immediate on B-Type
        X_addr_calc      <= std_logic_vector(signed(s_immediate(11 downto 0)) + signed(s_instAdr));
        -- check for opcodes and evaluate condition
        s_pc_jump_enable <= s_branch_jump_enable;
      when others =>
        s_pc_jump_enable <= "0";
        X_addr_calc      <= s_instAdr;
    end case;
  end process;

  -- process ram 
  ram_input : process(s_opcode, s_cycle_cnt)
  begin
    s_data_in_addr <= std_logic_vector(signed(s_immediate(11 downto 0)) + signed(s_reg_data1(11 downto 0)));
    if s_cycle_cnt = stWB then
      case s_opcode is
        when uSB | uSH | uSW => s_ram_enable <= "1";
        when others          => s_ram_enable <= "0";
      end case;
    else
      s_ram_enable <= "0";
    end if;
  end process;

  -- pc cycle control
  pc_cycle_control : process(s_clock)
  begin
    if rising_edge(s_clock) then
      case s_cycle_cnt is
        when stIF => s_cycle_cnt <= stDEC;
                     RGB2 <= "001";
        when stDEC => s_cycle_cnt <= stOF;
                      RGB2 <= "010";
        when stOF => s_cycle_cnt <= stEXEC;
                     RGB2 <= "011";
        when stEXEC => s_cycle_cnt <= stWB;
                       RGB2 <= "100";
        when others => s_cycle_cnt <= stIF;
                       RGB2 <= "101";
      end case;
    end if;
  end process pc_cycle_control;

end implementation;
