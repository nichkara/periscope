# Makefile for the different parts of the RISC-V COntroller
# Project by
# Yannick Reiß

# Variable section
PARTS		=	ram regs alu decoder pc cpu
CHDL		=	ghdl
FLAGS		=	--std=08
REGSSRC		=	src/riscv_types.vhd src/registers.vhd tb/tb_reg.vhd
ALUSRC		=	src/riscv_types.vhd src/alu.vhd tb/tb_alu.vhd
RAMSRC		=	src/riscv_types.vhd src/ram_block.vhd src/imem.vhd src/ram.vhd tb/tb_ram.vhd
PCSRC		=	src/riscv_types.vhd src/pc.vhd tb/tb_pc.vhd
DECSRC		=	src/riscv_types.vhd src/decoder.vhd tb/tb_decoder.vhd
CPUSRC		=	src/riscv_types.vhd src/ram_block.vhd src/branch.vhd src/imem.vhd src/ram.vhd src/registers.vhd src/alu.vhd src/pc.vhd src/decoder.vhd src/imm.vhd src/cpu.vhd tb/tb_cpu.vhd
ENTITY		=	regs_tb
ALUENTITY	=	alu_tb
PCENTITY	=	pc_tb
STOP		=	100us
TBENCH 		=	alu_tb regs_tb

# Build all
all: $(PARTS)

# ram testbench
ram: $(RAMSRC)
	$(CHDL) -a $(FLAGS) $(RAMSRC)
	$(CHDL) -e $(FLAGS) ram_tb
	$(CHDL) -r $(FLAGS) ram_tb --wave=ram_tb.ghw 

# registerbank testbench
regs: $(REGSSRC)
	$(CHDL) -a $(FLAGS) $(REGSSRC)
	$(CHDL) -e $(FLAGS) $(ENTITY)
	$(CHDL) -r $(FLAGS) $(ENTITY) --wave=$(ENTITY).ghw --stop-time=$(STOP)

# alu testbench
alu : $(ALUSRC)
	$(CHDL) -a $(FLAGS) $(ALUSRC)
	$(CHDL) -e $(FLAGS) $(ALUENTITY)
	$(CHDL) -r $(FLAGS) $(ALUENTITY) --wave=$(ALUENTITY).ghw --stop-time=$(STOP)

# pc testbench
pc : $(PCSRC)
	$(CHDL) -a $(FLAGS) $(PCSRC)
	$(CHDL) -e $(FLAGS) $(PCENTITY)
	$(CHDL) -r $(FLAGS) $(PCENTITY) --wave=$(PCENTITY).ghw --stop-time=$(STOP)

# decoder compilecheck
decoder:	$(DECSRC)
	$(CHDL) -a $(FLAGS) $(DECSRC)
	$(CHDL) -e $(FLAGS) decoder_tb
	$(CHDL) -r $(FLAGS) decoder_tb --wave=decode.ghw --stop-time=600ns

# cpu compilecheck
cpu:	$(CPUSRC)
	$(CHDL) -a $(FLAGS) $(CPUSRC)
	$(CHDL) -e $(FLAGS) cpu_tb
	$(CHDL) -r $(FLAGS) cpu_tb --wave=cpu.ghw --stop-time=60000ns

# imm compilecheck
imm:	src/imm.vhd
	$(CHDL) -a $(FLAGS) src/riscv_types.vhd src/imm.vhd tb/tb_imm.vhd
	$(CHDL) -e $(FLAGS) imm_tb
	$(CHDL) -r $(FLAGS) imm_tb --wave=imm.ghw --stop-time=600ns

# project rules
clean:
	find . -name '*.o' -exec rm -r {} \;
	find . -name '*.cf' -exec rm -r {} \;
	find . -name '*.ghw' -exec rm -r {} \;
	find . -name '*_tb' -exec rm -r {} \;
	rm alu_tb regs_tb decoder_tb ram_tb pc_tb

.PHONY: ram all regs cpu clean
