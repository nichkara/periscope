-- tb_pc.vhd
-- Created on: Mo 05. Dec 15:44:55 CET 2022
-- Author(s): Carl Ries, Yannick Reiß, Alexander Graf
-- Content: Testbench for program counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_types.all;

library std;
use std.textio.all;

-- Entity pc_tb: dummy entity
entity pc_tb is
end pc_tb;

-- Architecture testing of pc_tb: testing calculations
architecture testing of pc_tb is
	-- clock definition
	signal clk : std_logic;
	constant clk_period : time := 10 ns;

	-- Inputs pc	
	signal en_pc     : one_bit;
        signal addr_calc : ram_addr_t;
        signal doJump    : one_bit;
        
	-- Outputs pc
	signal addr      : ram_addr_t;
	
	-- unittest signals pc
	signal addr_calc_tb	: ram_addr_t;
	
begin
	-- Entity work.pc(pro_count): Init of Unit Under Test
	uut1 : entity work.pc
		port map (			
			clk		=> clk,
			en_pc		=> en_pc,
			addr_calc 	=> addr_calc,
			doJump		=> doJump,
			addr		=> addr
	);
	
	-- Process clk_process  operating the clock
	clk_process : process -- runs only, when  changed
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	-- Process stim_proc  control device for uut
	stim_proc : process -- runs only, when  changed
		-- Text I/O
		variable lineBuffer : line;
	begin
	   
		-- wait for the rising edge
		wait until rising_edge(clk);
		
		wait for 10 ns;
		
		-- Print the top element
		write(lineBuffer, string'("Start the simulator"));
		writeline(output, lineBuffer);

		-- testcases
		      
		-- Case 1: addr_calc
		write(lineBuffer, string'("Testing Case 1: "));
		writeline(output, lineBuffer);

		en_pc <= std_logic_vector(to_unsigned(1, 1));
		doJump <= std_logic_vector(to_unsigned(1, 1));
		addr_calc <= std_logic_vector(to_unsigned(30, ram_addr_size));
		wait for 10 ns;

		if addr = std_logic_vector(to_unsigned(30, ram_addr_size)) then 
			write(lineBuffer, string'("Result 1: +"));
			writeline(output, lineBuffer);
		else 
			write(lineBuffer, string'("Result 1: -"));
			writeline(output, lineBuffer);
		end if;
		
		-- Case 2: count
		write(lineBuffer, string'("Testing Case 2: "));
		writeline(output, lineBuffer);

		en_pc <= std_logic_vector(to_unsigned(1, 1));
		doJump <= std_logic_vector(to_unsigned(0, 1));
		addr_calc <= std_logic_vector(to_unsigned(60, ram_addr_size));
		wait for 10 ns;
		
		--same value from
		if addr = std_logic_vector(to_unsigned(31, ram_addr_size)) then 
			write(lineBuffer, string'("Result 2: +"));
			writeline(output, lineBuffer);
		else 
			write(lineBuffer, string'("Result 2: -"));
			writeline(output, lineBuffer);
		end if;

		-- Case 3: hold
		write(lineBuffer, string'("Testing Case 3: "));
		writeline(output, lineBuffer);

		en_pc <= std_logic_vector(to_unsigned(0, 1));
		doJump <= std_logic_vector(to_unsigned(0, 1));
		addr_calc <= std_logic_vector(to_unsigned(90, ram_addr_size));
		wait for 10 ns;
		
		--same value from
		if addr = std_logic_vector(to_unsigned(31, ram_addr_size)) then 
			write(lineBuffer, string'("Result 3: +"));
			writeline(output, lineBuffer);
		else 
			write(lineBuffer, string'("Result 3: -"));
			writeline(output, lineBuffer);
		end if;

		-- I'm still waiting
		wait;
	end process;
end testing;
		
		
		
		
