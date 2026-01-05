-- registers.vhd
-- Created on: So 13. Nov 19:06:55 CET 2022
-- Author(s): Nina Chloé Kassandra Reiß <nina.reiss@nickr.eu>
-- Content:  Entity registers

--------------------------------------------------------------
-- important constants and types from riscv_types (LN 104ff.)
--
-- constant reg_adr_size        :       integer := 5;
-- constant reg_size            :       integer := 32;
-- type         regFile is array (reg_size - 1 downto 0) of word;
--------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

-- Entity registers: entity defining the pins and ports of the registerblock
entity registers is
    generic (
        initRegs     :     regFile := (others => (others => '0'))
    );
    port (
        clk          : in  std_logic; -- input for clock (control device)
        reset        : in  std_logic;
        data_in      : in  word; -- Data to be written into the register
        wr_idx       : in  reg_idx; -- register to write to
        r1_idx       : in  reg_idx; -- first register to read from
        r2_idx       : in  reg_idx; -- second register to read from
        write_enable : in  std_logic; -- enable writing to wr_idx
        r1_out       : out word; -- data from first register
        r2_out       : out word -- data from second register
    );
end entity registers;

-- Architecture structure of registers: read from two, write to one
architecture structure of registers is
    signal registerbench : regFile;
begin

    process (clk, reset) is
    begin
        if reset = '0' then
            registerbench                                   <= initRegs;

        elsif rising_edge(clk) then
            if write_enable = '1' then
                registerbench(to_integer(unsigned(wr_idx))) <= data_in;
            end if;

            -- x0 immer 0 (RISC-V Regel)
            registerbench(0)                                <= (others => '0');
        end if;
    end process;

    -- read from both reading registers
    r1_out                                                  <= registerbench(to_integer(unsigned(r1_idx)));
    r2_out                                                  <= registerbench(to_integer(unsigned(r2_idx)));

end architecture structure;
