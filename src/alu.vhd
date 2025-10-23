-- alu.vhd
-- Created on: Mo 21. Nov 11:23:36 CET 2022
-- Author(s): Nina Chloé Kassandra Reiß <nina.reiss@nickr.eu>
-- Content: ALU
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.riscv_types.all;

entity alu is
    port (
        alu_opc : in  aluOP; -- alu opcode.
        input1  : in  word; -- input1 of alu (reg1 / pc address) rs1
        input2  : in  word; -- input2 of alu (reg2 / immediate)  rs2
        result  : out word -- alu output.
    );
end entity alu;

-- Architecture implementation of alu: implements operatings mode
architecture implementation of alu is

begin
    -- Process log  that fetches the opcode and executes it
    log: process (alu_opc, input1, input2) is                                                                               -- runs only, when all changed
    begin
        case alu_opc is
            when uNOP =>
                result     <= std_logic_vector(to_unsigned(0, wordWidth));                                                  -- no operations
            when uADD =>
                result     <= std_logic_vector(unsigned(input1) + unsigned(input2));                                        -- addition
            when uSUB =>
                result     <= std_logic_vector(signed(input1) - signed(input2));                                            -- subtraction
            when uSLL =>
                result     <= std_logic_vector(unsigned(input1) sll 1);                                                     -- shift left logical
            when uSLT =>
                if (signed(input1) < signed(input2)) then
                    result <= std_logic_vector(to_unsigned(1, wordWidth));
                else
                    result <= std_logic_vector(to_unsigned(0, wordWidth));
                end if;                                                                                                     -- Set lower than
            when uSLTU =>
                if (unsigned(input1) < unsigned(input2)) then
                    result <= std_logic_vector(to_unsigned(1, wordWidth));
                else
                    result <= std_logic_vector(to_unsigned(0, wordWidth));
                end if;                                                                                                     -- Set lower than unsigned
            when uXOR =>
                result     <= input1 xor input2;                                                                            -- exclusive or
            when uSRL =>
                result     <= std_logic_vector(unsigned(input1) srl 1);                                                     -- shift right logical
            when uSRA =>
                result     <= (input1 and b"10000000000000000000000000000000") or std_logic_vector(unsigned(input1) srl 1); -- shift right arithmetic
            when uOR =>
                result     <= input1 or input2;                                                                             -- or
            when uAND =>
                result     <= input1 and input2;                                                                            -- and
            when others =>
                result     <= std_logic_vector(to_unsigned(0, wordWidth));                                                  -- other operations return zero
        end case;
    end process log;
end architecture implementation;
