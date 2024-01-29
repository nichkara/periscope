-- branch.vhd
-- Created on: 19:01:2023
-- Author(s): Yannick Reiß
-- Copyright: WTFPL
-- Content: Entity branch - enable B-types in CPU
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.riscv_types.all;

entity Branch is
    port (
        op_code    : in  uOP;
        reg1       : in  word;
        reg2       : in  word;
        jmp_enable : out one_bit
        );
end Branch;

architecture arch of Branch is

begin

    branch_process : process(op_code)
    begin
        case op_code is
            when uBEQ =>
                if reg1 = reg2 then
                    jmp_enable <= "1";
                else
                    jmp_enable <= "0";
                end if;
            when uBNE =>
                if not (reg1 = reg2) then
                    jmp_enable <= "1";
                else
                    jmp_enable <= "0";
                end if;
            when uBLT =>
                if signed(reg1) < signed(reg2) then
                    jmp_enable <= "1";
                else
                    jmp_enable <= "0";
                end if;
            when uBGE =>
                if signed(reg1) >= signed(reg2) then
                    jmp_enable <= "1";
                else
                    jmp_enable <= "0";
                end if;
            when uBLTU =>
                if unsigned(reg1) < unsigned(reg2) then
                    jmp_enable <= "1";
                else
                    jmp_enable <= "0";
                end if;
            when uBGEU =>
                if unsigned(reg1) >= unsigned(reg2) then
                    jmp_enable <= "1";
                else
                    jmp_enable <= "0";
                end if;
            when others =>
                jmp_enable <= "0";
        end case;
    end process;  -- branch
end architecture;  -- arch
