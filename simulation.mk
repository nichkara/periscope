# ========================
# Configuration
# ========================
RISCV_PREFIX ?= riscv32-unknown-elf
ARCH         = rv32i
ABI          = ilp32

CC      = $(RISCV_PREFIX)-gcc
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
ROMVHDL = rom.vhd

# ========================
# Rules
# ========================
simulation: $(ROMVHDL)

$(ELF): $(SRC)
	$(CC) $(CFLAGS) -Ttext=0x00000000 $< -o $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary --only-section=.text $< $@

$(HEX): $(BIN)
	hexdump -v -e '1/4 "%08x\n"' $< > $@

$(ROMVHDL): $(HEX)
	@echo "library ieee;"                    >  $@
	@echo "use ieee.std_logic_1164.all;"     >> $@
	@echo "use ieee.numeric_std.all;"        >> $@
	@echo ""                                 >> $@
	@echo "package rom_pkg is"               >> $@
	@echo "  type rom_t is array (natural range <>) of std_logic_vector(31 downto 0);" >> $@
	@echo "  constant ROM : rom_t := ("       >> $@
	@awk '{ printf("    %d => x\"%s\",\n", NR-1, $$1) }' $(HEX) >> $@
	@echo "    others => x\"00000013\""       >> $@  # NOP
	@echo "  );"                              >> $@
	@echo "end package rom_pkg;"              >> $@

cleanup:
	rm -f $(ELF) $(BIN) $(HEX) $(ROMVHDL)

dump:
	$(OBJDUMP) -d $(ELF)

.PHONY: all cleanup dump
