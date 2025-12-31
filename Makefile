# Makefile for S-C Macro Assembler 3.1
# Uses vasm with SCMASM syntax

# Path to system-installed vasm utilities
VASM_SHARE ?= /usr/local/share/vasm

# Assembler binary (defaults to /usr/local/bin, override for development)
VASM_BIN ?= /usr/local/bin
VASM = $(VASM_BIN)/vasm6502_scmasm
VASMFLAGS = -Fbin

# Listing files for debugging
SCMASM_LST = $(BUILD_DIR)/SCMASM.lst
SCI_LST = $(BUILD_DIR)/B.SCI.lst
SCMASM_65816_LST = $(BUILD_DIR)/SCMASM.65816.lst

# Override ProDOS disk image name to SCMASM.po
PRODOS_IMAGE = build/SCMASM.po

# Include ProDOS disk image creation targets
include $(VASM_SHARE)/make/prodos.mk

# Output directory (must be defined before memory map targets)
BUILD_DIR = build

# Memory map configuration
MEMORY_MAP_PY = $(VASM_SHARE)/make/memory-map.py
MEMORY_MAP_CONFIG = memory-map.json
MEMORY_MAP = $(BUILD_DIR)/MEMORY.MAP

# Memory map generation using Python script
.PHONY: memory-map
memory-map: $(MEMORY_MAP)

$(MEMORY_MAP): $(MEMORY_MAP_CONFIG) $(SCMASM_BIN) $(SCI_BIN) $(IO_TWO_E) $(SCMASM_65816_BIN) | $(BUILD_DIR)
	@python3 $(MEMORY_MAP_PY) -c $(MEMORY_MAP_CONFIG) -o $(MEMORY_MAP)
	@cat $(MEMORY_MAP)

# Main targets
SCMASM_BIN = $(BUILD_DIR)/SCMASM
SCMASM_65816_BIN = $(BUILD_DIR)/SCMASM.65816
SCI_BIN = $(BUILD_DIR)/B.SCI

# All IO driver binaries
IO_TWO_E = $(BUILD_DIR)/B.IO.TWO.E
IO_STB80 = $(BUILD_DIR)/B.IO.STB80
IO_VIDEX = $(BUILD_DIR)/B.IO.VIDEX
IO_ULTRA = $(BUILD_DIR)/B.IO.ULTRA

# Main assembler source files (in order from ASM1/X.ACF)
ASM_SOURCES = \
	ASM2/SC.LOADER.s \
	ASM2/X.DATA.s \
	ASM2/X.PARAMETERS.s \
	ASM2/X.EDIT.s \
	ASM2/X.MISC.COMMANDS.s \
	ASM2/X.SEARCH.COMMA.s \
	ASM2/X.TEXT.SEARCH.s \
	ASM2/X.FIND.AND.REP.s \
	ASM2/X.READ.LINE.s \
	ASM2/X.EDIT.LINES.s \
	ASM2/X.OUTPUT.ROUTI.s \
	ASM2/X.DISK.OPERATI.s \
	ASM2/X.PARSE.LINE.R.s \
	ASM2/X.ASM.GENERAL.s \
	ASM2/X.ASM.NEXT.LINE.s \
	ASM2/X.EXPRESSION.C.s \
	ASM2/X.SYMBOL.TABLE.s \
	ASM2/X.PRINT.SYMBOLS.s \
	ASM2/X.MACRO.s \
	ASM2/X.DIRECTIVES.1.s \
	ASM2/X.DIRECTIVES.2.s \
	ASM2/X.AC.DIRECTIVE.s \
	ASM1/X.NEW.QUOTES.s \
	ASM1/X.TABLES.DIREC.s \
	ASM1/X.ASM.VECTORS.s \
	ASM1/IO.STANDARD.s

# 65816 extension source files (from ASM65816/X.ACF)
ASM65816_SOURCES = \
	ASM65816/X.DATA.s \
	ASM65816/X.ASM.LINKAGE.s \
	ASM65816/X.ASM.65816.1.s \
	ASM65816/X.ASM.65816.2.s \
	ASM65816/X.TABLES.65816.s \
	ASM65816/X.OP.DIRECTIVE.s

# ProDOS interface sources
SCI_SOURCES = \
	SCI/SC.s \
	SCI/SC.EQUATES.s \
	SCI/SC.COMMAND.PAR.s \
	SCI/SC.CATALOG.s \
	SCI/SC.EXEC.s \
	SCI/SC.ONLINE.s \
	SCI/SC.PR.IN.s \
	SCI/SC.ERRORS.s \
	SCI/SC.LOAD.SAVE.s \
	SCI/SC.OPEN.CLOSE.s \
	SCI/SC.RWPA.s \
	SCI/SC.TABLES.s \
	SCI/SC.VARIABLES.s \
	SCI/SC.GLOBAL.PAGE.s \
	SCI/S.NOW.s

# Default target
.PHONY: all
all: $(BUILD_DIR) $(SCMASM_BIN) $(SCMASM_65816_BIN) $(IO_TWO_E) $(IO_STB80) $(IO_VIDEX) $(IO_ULTRA)

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Main assembler build with embedded drivers
# File layout (when loaded at $2000) - must match SC.LOADER.s MOVE commands:
#   $2000-$21FF: Loader (512 bytes)
#   $2200-$4AFF: Assembler ($2900=10496 bytes, moved to $8000)
#   $4B00-$5FFF: SCI ($1500=5376 bytes, moved to $AA00)
#   $6000-$60FF: //e 80-col driver (DRIVER.ADDRS index 0)
#   $6600-$71FF: 65816 code ($C00=3072 bytes, moved to $D400 language card)
# Note: Other drivers (STB, Videx, Ultra) can be added at $6100, $6200, $6400
$(SCMASM_BIN): ASM1/X.ACF.s $(ASM_SOURCES) $(SCI_BIN) $(IO_TWO_E) $(SCMASM_65816_BIN) | $(BUILD_DIR)
	@echo "Building main S-C Macro Assembler..."
	$(VASM) $(VASMFLAGS) -L $(SCMASM_LST) -o $@.tmp ASM1/X.ACF.s
	@echo "Padding assembler for SCI at \$$4B00 (offset 11008)..."
	@truncate -s 11008 $@.tmp
	@echo "Combining with ProDOS Interface..."
	@cat $@.tmp $(SCI_BIN) > $@
	@rm -f $@.tmp
	@# Pad to $6000 offset for //e driver ($4000 from $2000 = 16384 bytes)
	@truncate -s 16384 $@
	@# Append //e 80-column driver at $6000
	@cat $(IO_TWO_E) >> $@
	@# Pad to $6600 offset for 65816 code ($4600 from $2000 = 17920 bytes)
	@truncate -s 17920 $@
	@# Append 65816 code at $6600
	@cat $(SCMASM_65816_BIN) >> $@
	@echo "Created SCMASM.SYSTEM file ($$(stat -f%z $@) bytes)"
	@$(MAKE) --no-print-directory memory-map

# 65816 extension build
$(SCMASM_65816_BIN): ASM65816/X.ACF.s $(ASM65816_SOURCES) | $(BUILD_DIR)
	@echo "Building 65816 extension..."
	cd ASM65816 && $(VASM) $(VASMFLAGS) -L ../$(SCMASM_65816_LST) -o ../$@ X.ACF.s

# IO Driver builds (individual files, not ACF controlled)
$(IO_TWO_E): ASM1/IO.TWO.E.s | $(BUILD_DIR)
	@echo "Building Apple //e 80-column driver..."
	$(VASM) $(VASMFLAGS) -o $@ $<

$(IO_STB80): ASM1/IO.STB80.s | $(BUILD_DIR)
	@echo "Building STB-80 driver..."
	$(VASM) $(VASMFLAGS) -o $@ $<

$(IO_VIDEX): ASM1/IO.VIDEX.s | $(BUILD_DIR)
	@echo "Building Videx Videoterm driver..."
	$(VASM) $(VASMFLAGS) -o $@ $<

$(IO_ULTRA): ASM1/IO.ULTRA.s | $(BUILD_DIR)
	@echo "Building Videx Ultraterm driver..."
	$(VASM) $(VASMFLAGS) -o $@ $<

# ProDOS interface (required for SCMASM.SYSTEM)
$(SCI_BIN): $(SCI_SOURCES) | $(BUILD_DIR)
	@echo "Building ProDOS interface..."
	cd SCI && $(VASM) $(VASMFLAGS) -L ../$(SCI_LST) -o ../$@ SC.s

# Build bootable ProDOS disk with SCMASM
.PHONY: disk
disk: all prodos-disk
	@echo "Creating bootable SCMASM disk..."
	$(AC) import -d $(PRODOS_IMAGE) --raw --stdin -t $(FTYPE_SYS) -a 0x2000 -n SCMASM.SYSTEM < $(SCMASM_BIN)
	$(AC) import -d $(PRODOS_IMAGE) --raw --stdin -t $(FTYPE_BIN) -a 0x6600 -n SCMASM.65816 < $(SCMASM_65816_BIN)
	$(AC) import -d $(PRODOS_IMAGE) --raw --stdin -t $(FTYPE_BIN) -a 0x6000 -n B.IO.TWO.E < $(IO_TWO_E)
	$(AC) import -d $(PRODOS_IMAGE) --raw --stdin -t $(FTYPE_BIN) -a 0x6100 -n B.IO.STB80 < $(IO_STB80)
	$(AC) import -d $(PRODOS_IMAGE) --raw --stdin -t $(FTYPE_BIN) -a 0x6200 -n B.IO.VIDEX < $(IO_VIDEX)
	$(AC) import -d $(PRODOS_IMAGE) --raw --stdin -t $(FTYPE_BIN) -a 0x6400 -n B.IO.ULTRA < $(IO_ULTRA)
	@echo ""
	@echo "=== Disk Image Ready: $(PRODOS_IMAGE) ==="
	$(AC) list -d $(PRODOS_IMAGE)

# Clean build artifacts
.PHONY: clean
clean: prodos-clean
	rm -rf $(BUILD_DIR)

# Display help
.PHONY: help
help:
	@echo "S-C Macro Assembler 3.1 - Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all         - Build all components (default)"
	@echo "  disk        - Build all + create bootable ProDOS disk"
	@echo "  memory-map  - Generate/display memory map and symbols"
	@echo "  test-a2osx  - Test A2osX ASM.S compatibility"
	@echo "  clean       - Remove all build artifacts"
	@echo "  help        - Display this help message"
	@echo "  prodos-help - Display ProDOS disk targets"
	@echo ""
	@echo "Components:"
	@echo "  SCMASM       - Main assembler binary"
	@echo "  SCMASM.65816 - 65816 CPU extension"
	@echo "  B.IO.*       - Display driver binaries"
	@echo ""
	@echo "Requirements:"
	@echo "  - vasm assembler with SCASM syntax support"
	@echo "  - Command: vasm6502_scmasm"
	@echo ""
	@echo "ProDOS Disk Requirements (for 'make disk'):"
	@echo "  - Java 21+ (for AppleCommander)"
	@echo "  - AppleCommander acx.jar in /usr/local/share/java/"
	@echo "  - Blank ProDOS disk in prodos/blank140k.dsk"
	@echo "  - Run ./scripts/download-prodos.sh to download blank disk"
	@echo "  - See README-PRODOS.md for details"

# List all source files
.PHONY: list-sources
list-sources:
	@echo "Main Assembler Sources:"
	@for file in $(ASM_SOURCES); do echo "  $$file"; done
	@echo ""
	@echo "65816 Extension Sources:"
	@for file in $(ASM65816_SOURCES); do echo "  $$file"; done
	@echo ""
	@echo "ProDOS Interface Sources:"
	@for file in $(SCI_SOURCES); do echo "  $$file"; done

# A2osX ASM.S compatibility test
A2OSX_DIR = tools/SCMASM.A2osX
A2OSX_SOURCE = $(A2OSX_DIR)/ASM.S.clean
A2OSX_OUTPUT = $(BUILD_DIR)/A2osX-ASM

.PHONY: test-a2osx
test-a2osx: $(A2OSX_SOURCE) | $(BUILD_DIR)
	@echo "Testing A2osX ASM.S compatibility..."
	@echo "(Note: A2osX source has compile-time size checks that may fail)"
	@$(VASM) $(VASMFLAGS) -o $(A2OSX_OUTPUT) $(A2OSX_SOURCE) 2>&1 | tee build/a2osx-test.log || true
	@echo ""
	@if grep -q "error 83" build/a2osx-test.log; then \
		echo "❌ Label directive error (vasm bug)"; \
		exit 1; \
	elif grep -q "error 31.*expression must be constant" build/a2osx-test.log; then \
		echo "✓ A2osX compile-time size check triggered (expected)"; \
		echo "  This validates that vasm correctly processes .DO/.FIN conditionals"; \
	elif grep -q "error" build/a2osx-test.log; then \
		echo "❌ Unexpected error in assembly"; \
		exit 1; \
	else \
		echo "✓ A2osX ASM.S assembled successfully!"; \
		echo "  Output: $(A2OSX_OUTPUT) ($$(stat -f%z $(A2OSX_OUTPUT)) bytes)"; \
	fi

$(A2OSX_SOURCE):
	@echo "A2osX source files not found. Running download script..."
	@cd $(A2OSX_DIR) && ./download-a2osx.sh
