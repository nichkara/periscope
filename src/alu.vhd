-- Alu.vhd
-- Created on: Mo 21. Nov 11:23:36 CET 2022
-- Author(s): Nina Chlóe Kassandra Reiß <nina.reiss@nickr.eu>
-- Content: ALU
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

entity Alu is
    port (
        Operation_Code : in  AluOP;
        Operand_1      : in  word;
        Operand_2      : in  word;
        Result         : out word
    );
end entity Alu;

-- Architecture implementation of Alu: implements operatings mode
architecture Implementation of Alu is

begin
    -- Process log  that fetches the opcode and executes it
    log: process (Operation_Code, Operand_1, Operand_2) is                                                           -- runs only, when all changed
    begin
        case Operation_Code is
            when uNOP =>
                Result     <= std_logic_vector(to_unsigned(0, wordWidth));                                           -- no operations
            when uADD =>
                Result     <= std_logic_vector(unsigned(Operand_1) + unsigned(Operand_2));                           -- addition
            when uSUB =>
                Result     <= std_logic_vector(signed(Operand_1) - signed(Operand_2));                               -- subtraction
            when uSLL =>
                Result     <= std_logic_vector(unsigned(Operand_1) sll to_integer(unsigned(Operand_2(4 downto 0)))); -- shift left logical
            when uSLT =>
                if (signed(Operand_1) < signed(Operand_2)) then
                    Result <= std_logic_vector(to_unsigned(1, wordWidth));
                else
                    Result <= std_logic_vector(to_unsigned(0, wordWidth));
                end if;                                                                                              -- Set lower than
            when uSLTU =>
                if (unsigned(Operand_1) < unsigned(Operand_2)) then
                    Result <= std_logic_vector(to_unsigned(1, wordWidth));
                else
                    Result <= std_logic_vector(to_unsigned(0, wordWidth));
                end if;                                                                                              -- Set lower than unsigned
            when uXOR =>
                Result     <= Operand_1 xor Operand_2;                                                               -- exclusive or
            when uSRL =>
                Result     <= std_logic_vector(unsigned(Operand_1) srl to_integer(unsigned(Operand_2(4 downto 0)))); -- shift right logical
            when uSRA =>
                Result     <=
                    (Operand_1 and b"10000000000000000000000000000000") or std_logic_vector(unsigned(Operand_1) srl
                        to_integer(unsigned(Operand_2(4 downto 0))));                                                -- shift right arithmetic
            when uOR =>
                Result     <= Operand_1 or Operand_2;                                                                -- or
            when uAND =>
                Result     <= Operand_1 and Operand_2;                                                               -- and
            when others =>
                Result     <= std_logic_vector(to_unsigned(0, wordWidth));                                           -- other operations return zero
        end case;
    end process log;
end architecture Implementation;
