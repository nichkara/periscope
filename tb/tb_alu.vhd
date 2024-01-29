-- tb_alu.vhd
-- Created on: Mo 21. Nov 11:21:12 CET 2022
-- Author(s): Carl Ries, Yannick Reiß, Alexander Graf
-- Content: Testbench for ALU
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.uniform;
use ieee.math_real.floor;

library work;
use work.riscv_types.all;

library std;
use std.textio.all;

-- Entity alu_tb: dummy entity
entity alu_tb is
end alu_tb;

-- Architecture testing of alu_tb: testing calculations
architecture testing of alu_tb is
    -- clock definition
    signal clk          : std_logic;
    constant clk_period : time := 10 ns;

    -- Inputs
    signal alu_opc_tb : aluOP;
    signal input1_tb  : word;
    signal input2_tb  : word;

    -- Outputs
    signal result_tb : word;

    -- unittest signals
    signal random_slv : word;
    signal check_slt  : word;
    signal check_sltu : word;
    signal rand_num   : integer := 0;

    -- function for random_std_logic_vector
    impure function get_random_slv return std_logic_vector is

        -- random number variabeln
        variable seed1 : integer := 1337;
        variable seed2 : integer := rand_num;  --Zufallszahl
        variable r     : real;
        variable slv   : std_logic_vector(wordWidth - 1 downto 0);

    begin
        for i in slv'range loop
            uniform(seed1, seed2, r);
            seed1  := seed1 + 2;
        end loop;
        seed2 := seed2 + 2;
        return slv;
    end function get_random_slv;

begin
    -- Entity work.alu(implementation): Init of Unit Under Test
    uut : entity work.alu(implementation)
        port map (
            alu_opc => alu_opc_tb,
            input1  => input1_tb,
            input2  => input2_tb,
            result  => result_tb
            );


    -- Process Random Integer
    rand_process : process  -- Prozess um einen Zufälligen Integer zu generieren

        variable seed1, seed2  : positive;         -- Startwert der Zufallszahl
        variable rand          : real;  -- Zufallszahl zwischen 0 und 1  
        variable range_of_rand : real := 10000.0;  -- Die Range  wird auf 10000 festgelegt

    begin
        uniform(seed1, seed2, rand);    -- Generiert Zufallszahl
        rand_num <= integer(rand*range_of_rand);  -- Zahl wird zwischen 0 und range_of_rand skaliert
        wait for 10 ns;
    end process;


    -- Process clk_process  operating the clock
    clk_process : process               -- runs only, when  changed
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Process stim_proc  control device for uut
    stim_proc : process                 -- runs only, when  changed
        -- Text I/O
        variable lineBuffer : line;
    begin
        -- wait for the rising edge
        wait until rising_edge(clk);

        -- Print the top element
        write(lineBuffer, string'("Start the simulator"));
        writeline(output, lineBuffer);

        -- For schleife für 20 Testdurchläufe
        for i in 1 to 20 loop

            --create  example inputs
            input1_tb  <= std_logic_vector( to_unsigned(10, 32) );
            wait for 10 ns;
            input2_tb  <= std_logic_vector( to_unsigned(7, 32) );
            alu_opc_tb <= uNop;
            wait for 10 ns;

            -- Ausgabe input1_tb und input2_tb
            -- Dient zur Kontrolle das zufällige Zahlen ausgegeben werden.
            write(lineBuffer, string'("Zufahlszahl 1: "));

            write(lineBuffer, string'("Zufahlszahl 2: "));

            -- NOP
            if (unsigned(result_tb) = 0) then
                write(lineBuffer, string'("NOP: +"));
                writeline(output, lineBuffer);
            else
                write(lineBuffer, string'("NOP: -"));
                writeline(output, lineBuffer);
            end if;
            alu_opc_tb <= uADD;
            wait for 10 ns;

            -- ADD
            if (unsigned(result_tb) = unsigned(input1_tb) + unsigned(input2_tb)) then
                write(lineBuffer, string'("ADD: +"));
                writeline(output, lineBuffer);
            else
                write(lineBuffer, string'("ADD: -"));
                writeline(output, lineBuffer);
            end if;
            alu_opc_tb <= uSUB;
            wait for 10 ns;

            -- SUB
            if (unsigned(result_tb) = unsigned(input1_tb) - unsigned(input2_tb)) then
                write(lineBuffer, string'("SUB: +"));
                writeline(output, lineBuffer);
            else
                write(lineBuffer, string'("SUB: -"));
                writeline(output, lineBuffer);
            end if;
            alu_opc_tb <= uSLL;
            wait for 10 ns;

            -- SLL
            if (unsigned(result_tb) = (unsigned(input1_tb) sll 1)) then
                write(lineBuffer, string'("SLL: +"));
                writeline(output, lineBuffer);
            else
                write(lineBuffer, string'("SLL: -"));
                writeline(output, lineBuffer);
            end if;
            alu_opc_tb <= uSLT;
            wait for 10 ns;

            -- SLT
            if(signed(input1_tb) < signed(input2_tb)) then
                check_slt <= std_logic_vector(to_unsigned(1, wordWidth));
            else
                check_slt <= std_logic_vector(to_unsigned(0, wordWidth));
            end if;  -- Set lower than
            wait for 10 ns;
            if (result_tb = check_slt) then
                write(lineBuffer, string'("SLT: +"));
                writeline(output, lineBuffer);
            else
                write(lineBuffer, string'("SLT: -"));
                writeline(output, lineBuffer);
            end if;
            alu_opc_tb <= uSLTU;
            wait for 10 ns;

            -- SLTU
            if(unsigned(input1_tb) < unsigned(input2_tb)) then
                check_sltu <= std_logic_vector(to_unsigned(1, wordWidth));
            else
                check_sltu <= std_logic_vector(to_unsigned(0, wordWidth));
            end if;  -- Set lower than unsigned
            wait for 10 ns;
            if (result_tb = check_sltu) then
                write(lineBuffer, string'("SLTU: +"));
                writeline(output, lineBuffer);
            else
                write(lineBuffer, string'("SLTU: -"));
                writeline(output, lineBuffer);
            end if;
            alu_opc_tb <= uXOR;
            wait for 10 ns;

            -- XOR
            if (result_tb = (input1_tb xor input2_tb)) then
                write(lineBuffer, string'("XOR: +"));
                writeline(output, lineBuffer);
            else
                write(lineBuffer, string'("XOR: -"));
                writeline(output, lineBuffer);
            end if;
            alu_opc_tb <= uSRL;
            wait for 10 ns;

            -- SRL
            if (unsigned(result_tb) = (unsigned(input1_tb) srl 1)) then
                write(lineBuffer, string'("SRL: +"));
                writeline(output, lineBuffer);
            else
                write(lineBuffer, string'("SRL: -"));
                writeline(output, lineBuffer);
            end if;
            alu_opc_tb <= uSRA;
            wait for 10 ns;

            -- SRA
            if (unsigned(result_tb) = unsigned(std_logic_vector(to_stdlogicvector(to_bitvector(input1_tb) sra 1)))) then
                write(lineBuffer, string'("SRA: +"));
                writeline(output, lineBuffer);
            else
                write(lineBuffer, string'("SRA: -"));
                writeline(output, lineBuffer);
            end if;
            alu_opc_tb <= uOR;
            wait for 10 ns;

            -- OR
            if (result_tb = (input1_tb or input2_tb)) then
                write(lineBuffer, string'("OR: +"));
                writeline(output, lineBuffer);
            else
                write(lineBuffer, string'("OR: -"));
                writeline(output, lineBuffer);
            end if;
            alu_opc_tb <= uAND;
            wait for 10 ns;

            -- AND
            if (result_tb = (input1_tb and input2_tb)) then
                write(lineBuffer, string'("AND: +"));
                writeline(output, lineBuffer);
            else
                write(lineBuffer, string'("AND: -"));
                writeline(output, lineBuffer);
            end if;

        -- end loop
        end loop;

        -- end simulation
        write(lineBuffer, string'("end of simulation"));
        writeline(output, lineBuffer);

        -- I'm still waiting
        wait;
    end process;
end testing;

