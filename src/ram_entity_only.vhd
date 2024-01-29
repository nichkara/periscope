-- Created on: Do 3. Nov 20:11:50 CET 2022
-- Author(s): Alexander Graf, Carl Ries, Yannick Reiß
-- Content: Entity ram and architecture of ram
library work;
use work.riscv_types.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity ram: Ram storage
entity ram is

  generic (zeros : ram_t := (others => (others => '0')));
  port(
    clk            : in std_logic;      -- Clock input for timing
    instructionAdr : in ram_addr_t;     -- Address instruction
    dataAdr        : in ram_addr_t;     -- Address data

    writeEnable : in one_bit;           -- Read or write mode

    dataIn      : in  word;             -- Write data
    instruction : out word;             -- Get instruction
    dataOut     : out word              -- Read data
    );
end ram;

-- Architecture behavioral of ram: control different ram blocks
architecture behavioral of ram is
  -- write signals
  signal wr1 : one_bit := "0";
  signal wr2 : one_bit := "0";
  signal wr3 : one_bit := "0";
  signal wr4 : one_bit := "0";

  -- instruction signals
  signal inst1 : std_logic_vector(wordWidth - 1 downto 0);
  signal inst2 : std_logic_vector(wordWidth - 1 downto 0);
  signal inst3 : std_logic_vector(wordWidth - 1 downto 0);
  signal inst4 : std_logic_vector(wordWidth - 1 downto 0);

  -- data signals
  signal data1 : std_logic_vector(wordWidth - 1 downto 0);
  signal data2 : std_logic_vector(wordWidth - 1 downto 0);
  signal data3 : std_logic_vector(wordWidth - 1 downto 0);
  signal data4 : std_logic_vector(wordWidth - 1 downto 0);

begin

  block1 : entity work.instr_memory(behavioral)
    port map (
      clk          => clk,
      addr_a       => instructionAdr(ram_addr_size - 3 downto 0),
      write_b      => wr1,
      addr_b       => dataAdr(ram_addr_size - 3 downto 0),
      data_write_b => dataIn,

      data_read_a => inst1,
      data_read_b => data1
      );

  block2 : entity work.ram_block(behavioral)
    port map (
      clk          => clk,
      addr_a       => instructionAdr(9 downto 0),
      write_b      => wr2,
      addr_b       => dataAdr(9 downto 0),
      data_write_b => dataIn,

      data_read_a => inst2,
      data_read_b => data2
      );

  block3 : entity work.ram_block(behavioral)
    port map (
      clk          => clk,
      addr_a       => instructionAdr(9 downto 0),
      write_b      => wr3,
      addr_b       => dataAdr(9 downto 0),
      data_write_b => dataIn,

      data_read_a => inst3,
      data_read_b => data3
      );

  block4 : entity work.ram_block(behavioral)
    port map (
      clk          => clk,
      addr_a       => instructionAdr(9 downto 0),
      write_b      => wr4,
      addr_b       => dataAdr(9 downto 0),
      data_write_b => dataIn,

      data_read_a => inst4,
      data_read_b => data4
      );

  addr_block : process (data1, data2, data3, data4, dataAdr(11 downto 10),
                        inst1, inst2, inst3, inst4,
                        instructionAdr(11 downto 10), writeEnable)  -- run process addr_block when list changes
  begin
    -- enable write
    case dataAdr(11 downto 10) is
      when "00" =>
        wr1 <= writeEnable;
        wr2 <= "0";
        wr3 <= "0";
        wr4 <= "0";
      when "01" =>
        wr1 <= "0";
        wr2 <= writeEnable;
        wr3 <= "0";
        wr4 <= "0";
      when "10" =>
        wr1 <= "0";
        wr2 <= "0";
        wr3 <= writeEnable;
        wr4 <= "0";
      when "11" =>
        wr1 <= "0";
        wr2 <= "0";
        wr3 <= "0";
        wr4 <= writeEnable;
      when others =>
        wr1 <= "0";
        wr2 <= "0";
        wr3 <= "0";
        wr4 <= "0";
    end case;

    -- instruction data
    case instructionAdr(11 downto 10) is
      when "00"   => instruction <= inst1;
      when "01"   => instruction <= inst2;
      when "10"   => instruction <= inst3;
      when others => instruction <= inst4;
    end case;

    -- data data
    case dataAdr(11 downto 10) is
      when "00"   => dataOut <= data1;
      when "01"   => dataOut <= data2;
      when "10"   => dataOut <= data3;
      when others => dataOut <= data4;
    end case;
  end process;
end behavioral;
