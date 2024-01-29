-- tb_reg.vhd
-- Created on: Mo 14. Nov 11:55:58 CET 2022
-- Author(s): Yannick Reiß, Alexander Graf, Carl Ries
-- Content: Testbench for the registerblock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.uniform;

library work;
use work.riscv_types.all;

library std;
use  std.textio.all;

-- Entity regs_tb: Entity providing testinputs, receiving testoutputs for registerbench
entity regs_tb is
end regs_tb;

-- Architecture testing of regs_tb: testing read / write operations
architecture testing of regs_tb is
	-- clock definition
	signal clk : std_logic;
	constant clk_period : time := 10 ns;

	-- Inputs
	signal en_reg_wb_tb : one_bit;
	signal data_in_tb : word;
	signal wr_idx_tb : reg_idx;
	signal r1_idx_tb : reg_idx;
	signal r2_idx_tb : reg_idx;
	signal write_enable_tb : one_bit;

	-- Outputs
	signal r1_out_tb : word;
	signal r2_out_tb : word;

	-- unittest signals
	signal random_slv: word;
	
	--function for random_std_logic_vector
	function get_random_slv return std_logic_vector is
	
		-- random number variablen
		variable seed1	 : integer := 1;
		variable seed2	 : integer := 1;
		variable r	 : real;
		variable slv	 : std_logic_vector(wordWidth - 1 downto 0);

	begin
		for i in slv'range loop
			uniform(seed1, seed2, r);
			slv(i) := '1' when r > 0.5 else '0';
		end loop;
		return slv;
	end function;

begin
	
	-- Init of Unit Under Test
	uut : entity work.registers(Structure)
		port map (
			clk => clk,
			en_reg_wb => en_reg_wb_tb,
			data_in => data_in_tb,
			wr_idx => wr_idx_tb,
			r1_idx => r1_idx_tb,
			r2_idx => r2_idx_tb,
			write_enable => write_enable_tb,
			r1_out => r1_out_tb,
			r2_out => r2_out_tb
		);

	-- Process clk_process  operating the clock
	clk_process : process -- runs always
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
	
	-- Stimulating the UUT
	-- Process stim_proc  control device for 
	stim_proc : process
		-- Text I/O
		variable lineBuffer : line;
		
	begin
		
		-- wait for the rising edge
		wait until rising_edge(clk);
		
		wait for 5 ns;
	
		-- Print the top element
		write(lineBuffer, string'("Start the simulation: "));
		writeline(output, lineBuffer);

		-- set the stimuli here
	
		-- Case 1: write to x=7 + read x=4
		write(lineBuffer, string'("Testing Case 1: "));
		writeline(output, lineBuffer);

		write_enable_tb <= std_logic_vector(to_unsigned(1, 1));
		data_in_tb<= std_logic_vector(to_unsigned(7, wordWidth));
		wr_idx_tb <= std_logic_vector(to_unsigned(7, reg_adr_size));
		r1_idx_tb <= std_logic_vector(to_unsigned(4, reg_adr_size));
		r2_idx_tb <= std_logic_vector(to_unsigned(7, reg_adr_size));
		wait for 10 ns;

		if r1_out_tb = std_logic_vector(to_unsigned(0, wordWidth)) and r2_out_tb = std_logic_vector(to_unsigned(7, wordWidth)) then 
			write(lineBuffer, string'("Result 1: +"));
			writeline(output, lineBuffer);
		else 
			write(lineBuffer, string'("Result 1: -"));
			writeline(output, lineBuffer);
		end if;

		-- Case 2: write to x=27 + read x=0
		write(lineBuffer, string'("Testing Case 2: "));
		writeline(output, lineBuffer);

		write_enable_tb <= std_logic_vector(to_unsigned(1, 1));
		data_in_tb<= std_logic_vector(to_unsigned(7, wordWidth));
		wr_idx_tb <= std_logic_vector(to_unsigned(27, reg_adr_size));
		r1_idx_tb <= std_logic_vector(to_unsigned(0, reg_adr_size));
		r2_idx_tb <= std_logic_vector(to_unsigned(27, reg_adr_size));
		wait for 10 ns;

		if r1_out_tb = std_logic_vector(to_unsigned(0, wordWidth)) and r2_out_tb = std_logic_vector(to_unsigned(7, wordWidth)) then 
			write(lineBuffer, string'("Result 2: +"));
			writeline(output, lineBuffer);
		else 
			write(lineBuffer, string'("Result 2: -"));
			writeline(output, lineBuffer);
		end if;

		-- Case 3: write to zero + read from zero x2
		write(lineBuffer, string'("Testing Case 3: "));
		writeline(output, lineBuffer);

		write_enable_tb <= std_logic_vector(to_unsigned(1, 1));
		data_in_tb<= std_logic_vector(to_unsigned(7, wordWidth));
		wr_idx_tb <= std_logic_vector(to_unsigned(0, reg_adr_size));
		r1_idx_tb <= std_logic_vector(to_unsigned(0, reg_adr_size));
		r2_idx_tb <= std_logic_vector(to_unsigned(27, reg_adr_size));
		wait for 10 ns;

		if r1_out_tb = std_logic_vector(to_unsigned(0, wordWidth)) then 
			write(lineBuffer, string'("Result 3: +"));
			writeline(output, lineBuffer);
		else 
			write(lineBuffer, string'("Result 3: -"));
			writeline(output, lineBuffer);
		end if;

		-- Case 4: write to 31 + read from 31
		write(lineBuffer, string'("Testing Case 4: "));
		writeline(output, lineBuffer);

		write_enable_tb <= std_logic_vector(to_unsigned(1, 1));
		data_in_tb<= std_logic_vector(to_unsigned(7, wordWidth));
		wr_idx_tb <= std_logic_vector(to_unsigned(31, reg_adr_size));
		r1_idx_tb <= std_logic_vector(to_unsigned(31, reg_adr_size));
		r2_idx_tb <= std_logic_vector(to_unsigned(0, reg_adr_size));
		wait for 10 ns;

		if r1_out_tb = std_logic_vector(to_unsigned(7, wordWidth)) then 
			write(lineBuffer, string'("Result 4: +"));
			writeline(output, lineBuffer);
		else 
			write(lineBuffer, string'("Result 4: -"));
			writeline(output, lineBuffer);
		end if;

		-- Case 5: read x=7 + read x=18
		write(lineBuffer, string'("Testing Case 5: "));
		writeline(output, lineBuffer);

		write_enable_tb <= std_logic_vector(to_unsigned(0, 1));
		data_in_tb<= std_logic_vector(to_unsigned(9, wordWidth));
		wr_idx_tb <= std_logic_vector(to_unsigned(7, reg_adr_size));
		r1_idx_tb <= std_logic_vector(to_unsigned(7, reg_adr_size));
		r2_idx_tb <= std_logic_vector(to_unsigned(18, reg_adr_size));
		wait for 10 ns;
		
		-- Not allowed to change, last value was 7, new "would" be 9
		if r1_out_tb = std_logic_vector(to_unsigned(7, wordWidth)) then 
			write(lineBuffer, string'("Result 5: +"));
			writeline(output, lineBuffer);
		else 
			write(lineBuffer, string'("Result 5: -"));
			writeline(output, lineBuffer);
		end if;
		
		-- Case 6: RANDOM_Test write to 12 + read from 12
		write(lineBuffer, string'("Testing Case 6: "));
		writeline(output, lineBuffer);
		
		-- get random_logic_vector
		random_slv <= get_random_slv;
		
		wait for 10 ns;
		
		write_enable_tb <= std_logic_vector(to_unsigned(1, 1));
		data_in_tb	<= random_slv;
		wr_idx_tb	<= std_logic_vector(to_unsigned(12, reg_adr_size));
		r1_idx_tb	<= std_logic_vector(to_unsigned(12, reg_adr_size));
		r2_idx_tb	<= std_logic_vector(to_unsigned(0, reg_adr_size));
		wait for 10 ns;
		
		if r1_out_tb = random_slv then 
			write(lineBuffer, string'("Result 6: +"));
			writeline(output, lineBuffer);
		else 
			write(lineBuffer, string'("Result 6: -"));
			writeline(output, lineBuffer);
		end if;
		
		-- end simulation
		write(lineBuffer, string'("end of simulation"));
		writeline(output, lineBuffer);

		-- I'm still waiting
		wait;
	end process;
	
end testing;
