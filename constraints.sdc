create_clock -name clk -period 20 [get_ports clk]

set_input_delay  2 -clock clk [all_inputs]
set_output_delay 2 -clock clk [all_outputs]

set_clock_uncertainty 0.5 [get_clocks clk]
