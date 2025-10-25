#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>

int main(void) {

    /* Print docstring */
    (void)printf("-- tb_alu.vhd\n");
    (void)printf("-- Created on: Mo 21. Nov 11:21:12 CET 2022\n");
    (void)printf("-- Author(s): Nina Chloé Kassandra Reiß <nina.reiss@nickr.eu>\n");
    (void)printf("-- Content: Testbench for ALU\n");

    /* print libraries */
    (void)printf("library ieee;\n");
    (void)printf("use ieee.std_logic_1164.all;\n");
    (void)printf("use ieee.numeric_std.all;\n");
    (void)printf("use ieee.math_real.uniform;\n");
    (void)printf("use ieee.math_real.floor;\n");
    (void)printf("use work.riscv_types.all;\n");
    (void)printf("library std;\n");
    (void)printf("use std.textio.all;\n");
    (void)printf("use std.env.finish;\n");

    /* Entity for testing */
    (void)printf("entity alu_tb is\n");
    (void)printf("end alu_tb;\n");

    /* Architecture */
    (void)printf("-- Architecture testing of alu_tb: testing calculations\n");
    (void)printf("architecture testing of alu_tb is\n");
    (void)printf("    -- clock definition\n");
    (void)printf("    signal clk          : std_logic;\n");
    (void)printf("    constant clk_period : time := 10 ns;\n");
    (void)printf("    -- Inputs\n");
    (void)printf("    signal alu_opc_tb : aluOP;\n");
    (void)printf("    signal input1_tb  : word;\n");
    (void)printf("    signal input2_tb  : word;\n");
    (void)printf("    -- Outputs\n");
    (void)printf("    signal result_tb : word;\n");
    (void)printf("    signal verify : word;\n");
    (void)printf("begin\n");
    (void)printf("    -- Entity work.alu(implementation): Init of Unit Under Test\n");
    (void)printf("    uut : entity work.alu(implementation)\n");
    (void)printf("        port map (\n");
    (void)printf("            alu_opc => alu_opc_tb,\n");
    (void)printf("            input1  => input1_tb,\n");
    (void)printf("            input2  => input2_tb,\n");
    (void)printf("            result  => result_tb\n");
    (void)printf("            );\n"                );
    (void)printf("    -- Process clk_process  operating the clock\n");
    (void)printf("    clk_process : process               -- runs only, when  changed\n");
    (void)printf("    begin\n");
    (void)printf("        clk <= '0';\n");
    (void)printf("        wait for clk_period/2;\n");
    (void)printf("        clk <= '1';\n");
    (void)printf("        wait for clk_period/2;\n");
    (void)printf("    end process;\n");
    (void)printf("    -- Process stim_proc  control device for uut\n");
    (void)printf("    stim_proc : process                 -- runs only, when  changed\n");
    (void)printf("        -- Text I/O\n");
    (void)printf("        variable lineBuffer : line;\n");
    (void)printf("    begin\n");
    (void)printf("        -- wait for the rising edge\n");
    (void)printf("        wait until rising_edge(clk);\n");
    (void)printf("        -- Print the top element\n");
    (void)printf("        write(lineBuffer, string'(\"Start the simulator\"));\n");
    (void)printf("        writeline(output, lineBuffer);\n");

    /* Generate random cases */
    u_int32_t left;
    u_int32_t right;

    for (left = 0; left < 73; left ++) {
        for (right = 0; right < 73; right ++) {
            (void)printf("      input1_tb <= std_logic_vector(to_unsigned(%u, 32));\n", (unsigned int)(left & 2147483647));
            (void)printf("      input2_tb <= std_logic_vector(to_unsigned(%u, 32));\n", (unsigned int)(right & 2147483647));
            (void)printf("      alu_opc_tb <= uNop;\n");
            (void)printf("      wait for 10 ns;\n");
            (void)printf("      assert result_tb = x\"00000000\" report \"Nop Error\" severity failure;\n");

            (void)printf("      alu_opc_tb <= uAdd;\n");
            (void)printf("      verify <= x\"%08x\";\n", left + right);
            (void)printf("      wait for 10 ns;\n");
            (void)printf("      assert result_tb = verify report \"Add Error\" severity failure;\n");

            (void)printf("      alu_opc_tb <= uSub;\n");
            (void)printf("      verify <= x\"%08x\";\n", (unsigned int)((left - right) & (4294967295)));
            (void)printf("      wait for 10 ns;\n");
            (void)printf("      assert result_tb = verify report \"Sub Error\" severity failure;\n");

            (void)printf("      alu_opc_tb <= uSLL;\n");
            (void)printf("      verify <= x\"%08x\";\n", (unsigned int)((left << right) & 4294967295));
            (void)printf("      wait for 10 ns;\n");
            (void)printf("      assert result_tb = verify report \"SLL Error\" severity failure;\n");

            (void)printf("      alu_opc_tb <= uSLT;\n");
            (void)printf("      verify <= x\"%08x\";\n", (unsigned int)((int)left < (int)right));
            (void)printf("      wait for 10 ns;\n");
            (void)printf("      assert result_tb = verify report \"SLT Error\" severity failure;\n");

            (void)printf("      alu_opc_tb <= uSLTU;\n");
            (void)printf("      verify <= x\"%08x\";\n", (unsigned int)((unsigned)left < (unsigned)right));
            (void)printf("      wait for 10 ns;\n");
            (void)printf("      assert result_tb = verify report \"SLTU Error\" severity failure;\n");

            (void)printf("      alu_opc_tb <= uXOR;\n");
            (void)printf("      verify <= x\"%08x\";\n", (unsigned int)((unsigned)left ^ (unsigned)right));
            (void)printf("      wait for 10 ns;\n");
            (void)printf("      assert result_tb = verify report \"XOR Error\" severity failure;\n");

            (void)printf("      alu_opc_tb <= uSRL;\n");
            (void)printf("      verify <= x\"%08x\";\n", (unsigned int)(left >> right));
            (void)printf("      wait for 10 ns;\n");
            (void)printf("      assert result_tb = verify report \"SRL Error\" severity failure;\n");

            (void)printf("      alu_opc_tb <= uOR;\n");
            (void)printf("      verify <= x\"%08x\";\n", (unsigned int)((unsigned)left | (unsigned)right));
            (void)printf("      wait for 10 ns;\n");
            (void)printf("      assert result_tb = verify report \"OR Error\" severity failure;\n");

            (void)printf("      alu_opc_tb <= uAND;\n");
            (void)printf("      verify <= x\"%08x\";\n", (unsigned int)(left & right));
            (void)printf("      wait for 10 ns;\n");
            (void)printf("      assert result_tb = verify report \"AND Error\" severity failure;\n");
        }
    }

    (void)printf("        -- end simulation\n");
    (void)printf("        write(lineBuffer, string'(\"end of simulation\"));\n");
    (void)printf("        writeline(output, lineBuffer);\n");
    (void)printf("        finish;\n");
    (void)printf("    end process;\n");
    (void)printf("end testing;\n");

    return 0;
}
