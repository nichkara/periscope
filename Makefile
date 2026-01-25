# Makefile for the different parts of the RISC-V Controller
# Project by
# Nina Chloé Kassandra Reiß <nina.reiss@nickr.eu>
include simulation.mk
include fpga.mk

# Variable section
PARTS		=	memory_read_write regs alu decoder pc cpu shift_register
CHDL		=	ghdl
FLAGS		=	--std=08
REGSSRC		=	src/riscv_types.vhd src/register_cluster.vhd tb/tb_register_cluster.vhd
ALUSRC		=	src/riscv_types.vhd src/alu.vhd tb/tb_alu.vhd
RAMSRC		=	src/riscv_types.vhd src/rom.vhd src/memory_block.vhd src/memory.vhd tb/tb_memory.vhd
PCSRC		=	src/riscv_types.vhd src/pc.vhd tb/tb_pc.vhd
DECSRC		=	src/riscv_types.vhd src/decoder.vhd tb/tb_decoder.vhd
SREG 		= 	src/riscv_types.vhd src/shift_register.vhd tb/tb_shift_register.vhd
CPUSRC		=	src/riscv_types.vhd src/alu.vhd src/decoder.vhd src/imm.vhd src/pc.vhd src/register_cluster.vhd src/pipeline.vhd src/cpu.vhd tb/tb_cpu.vhd
ENTITY		=	Register_Cluster_Testbench
ALUENTITY	=	alu_tb
PCENTITY	=	pc_tb
STOP		=	100us
TBENCH 		=	alu_tb Register_Cluster_Testbench
NOTBSRC		=	src/riscv_types.vhd src/rom.vhd src/memory_block.vhd src/branch.vhd src/memory.vhd src/register_cluster.vhd src/alu.vhd src/pc.vhd src/decoder.vhd src/imm.vhd src/cpu.vhd

# Build all
all: $(PARTS)

# ram testbench
memory_read_write:
	$(CHDL) -a $(FLAGS) $(RAMSRC)
	$(CHDL) -e $(FLAGS) Memory_Testbench
	$(CHDL) -r $(FLAGS) Memory_Testbench --wave=testbench.ghw

# registerbank testbench
regs: $(REGSSRC)
	$(CHDL) -a $(FLAGS) $(REGSSRC)
	$(CHDL) -e $(FLAGS) $(ENTITY)
	$(CHDL) -r $(FLAGS) $(ENTITY)

# alu testbench
alu :
	$(CC) -o alu_tb -Wall -Werror tb/tb_alu.c
	./alu_tb > tb/tb_alu.vhd
	rm ./alu_tb
	$(CHDL) -a $(FLAGS) $(ALUSRC)
	$(CHDL) -e $(FLAGS) $(ALUENTITY)
	$(CHDL) -r $(FLAGS) $(ALUENTITY) --wave=testbench.ghw

# decoder compilecheck
decoder:	$(DECSRC)
	$(CHDL) -a $(FLAGS) $(DECSRC)
	$(CHDL) -e $(FLAGS) decoder_tb
	$(CHDL) -r $(FLAGS) decoder_tb --wave=decode.ghw --stop-time=600ns

# shift_register compilecheck
shift_register:	$(SREG)
	$(CHDL) -a $(FLAGS) $(SREG)
	$(CHDL) -e $(FLAGS) Shift_Register_Testbench
	$(CHDL) -r $(FLAGS) Shift_Register_Testbench --wave=testbench.ghw --stop-time=1200ns

# cpu compilecheck
cpu:	$(CPUSRC)
	$(CHDL) -a $(FLAGS) $(CPUSRC)
	$(CHDL) -e $(FLAGS) cpu_tb
	$(CHDL) -r $(FLAGS) cpu_tb --wave=testbench.ghw --stop-time=600000ns

raw:	$(NOTBSRC)
	$(CHDL) -a $(FLAGS) $(NOTBSRC)

# project rules
clean:
	make cleanup
	find . -name '*.o' -exec rm -r {} \;
	find . -name '*.cf' -exec rm -r {} \;
	find . -name '*.ghw' -exec rm -r {} \;
	find . -name '*_tb' -exec rm -r {} \;
	rm alu_tb Register_Cluster_Testbench decoder_tb ram_tb pc_tb

.PHONY: memory_read_write all regs cpu clean raw shift_register
