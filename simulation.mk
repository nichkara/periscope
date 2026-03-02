# ========================
# Configuration
# ========================
RISCV_PREFIX ?= riscv32-none-elf
ARCH         = rv32i
ABI          = ilp32

RVCC      = $(RISCV_PREFIX)-gcc
AS      = $(RISCV_PREFIX)-as
OBJCOPY = $(RISCV_PREFIX)-objcopy
OBJDUMP = $(RISCV_PREFIX)-objdump

CFLAGS  = -march=$(ARCH) -mabi=$(ABI) \
          -ffreestanding -fno-builtin -nostdlib \
          -O0 -Wall

ASFLAGS = -march=$(ARCH) -mabi=$(ABI)

# ========================
# Files
# ========================
SRC     = main.c
ELF     = main.elf
BIN     = main.bin
HEX     = main.hex
ROMVHDL = src/rom.vhd

# ========================
# Rules
# ========================
simulation: $(ROMVHDL)

$(ELF): $(SRC)
	$(RVCC) $(CFLAGS) -Ttext=0x00000000 $< -o $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary --only-section=.text $< $@

$(HEX): $(BIN)
	hexdump -v -e '1/4 "%08x\n"' $< > $@

$(ROMVHDL): $(HEX)
	@echo "library ieee;"                    >  $@
	@echo "use ieee.std_logic_1164.all;"     >> $@
	@echo "use ieee.numeric_std.all;"        >> $@
	@echo "use work.riscv_types.all;"        >> $@
	@echo ""                                 >> $@
	@echo "package Bios is"               >> $@
	@echo "  constant Rom : ram_t := ("       >> $@
	@awk '{ printf("    %d => x\"%s\",\n", NR-1, $$1) }' $(HEX) >> $@
	@echo "    others => x\"00000013\""       >> $@  # NOP
	@echo "  );"                              >> $@
	@echo "end package Bios;"              >> $@

cleanup:
	rm -f $(ELF) $(BIN) $(HEX) $(ROMVHDL)

dump:
	$(OBJDUMP) -d $(ELF)

.PHONY: simulation cleanup dump
