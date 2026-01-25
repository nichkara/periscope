DEVICE	=	GW1NR-LV9QN88PC6/I5
BOARD	=	tangnano9k
VENV	=	venv
TOOLS	=	tools

.PHONY: fpga_example
fpga_example: $(VENV)
	wget -O blinky.v https://raw.githubusercontent.com/YosysHQ/apicula/refs/heads/master/examples/blinky.v
	wget -O $(BOARD).cst https://raw.githubusercontent.com/YosysHQ/apicula/refs/heads/master/examples/tangnano9k.cst
	yosys -D INV_BTN="clk" -D LEDS_NR=6 -p "read_verilog blinky.v; synth_gowin -json blinky.json"
	nextpnr-himbaechel --json blinky.json \
                   --write pnrblinky.json \
                   --device $(DEVICE) \
                   --vopt family=GW1N-9C \
                   --vopt cst=$(BOARD).cst
	gowin_pack -d GW1N-9C -o pack.fs pnrblinky.json
	openFPGALoader -b $(BOARD) pack.fs
	rm -f blinky.v
	rm -f $(BOARD).cst

.PHONY: $(VENV)
$(VENV):
	rm -rf $(VENV)
	python -m venv $(VENV)
	./$(VENV)/bin/pip install apycula
