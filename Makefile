# Makefile for S-C Macro Assembler 3.1
# Uses vasm with SCASM syntax

# Assembler
VASM = vasm6502_scasm
VASMFLAGS = -Fbin

# Include ProDOS disk image creation targets
include prodos.mk

# Output directory
BUILD_DIR = build

# Main targets
SCASM_BIN = $(BUILD_DIR)/SCASM
SCASM_65816_BIN = $(BUILD_DIR)/SCASM.65816
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
all: $(BUILD_DIR) $(SCASM_BIN) $(SCASM_65816_BIN) $(IO_TWO_E) $(IO_STB80) $(IO_VIDEX) $(IO_ULTRA)

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Main assembler build
$(SCASM_BIN): ASM1/X.ACF.s $(ASM_SOURCES) | $(BUILD_DIR)
	@echo "Building main S-C Macro Assembler..."
	$(VASM) $(VASMFLAGS) -o $@ ASM1/X.ACF.s

# 65816 extension build
$(SCASM_65816_BIN): ASM65816/X.ACF.s $(ASM65816_SOURCES) | $(BUILD_DIR)
	@echo "Building 65816 extension..."
	cd ASM65816 && $(VASM) $(VASMFLAGS) -o ../$@ X.ACF.s

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

# ProDOS interface (if needed separately)
$(SCI_BIN): $(SCI_SOURCES) | $(BUILD_DIR)
	@echo "Building ProDOS interface..."
	$(VASM) $(VASMFLAGS) -o $@ SCI/SC.s

# Build bootable ProDOS disk with SCASM
.PHONY: disk
disk: all prodos-disk
	@echo "Creating bootable SCASM disk..."
	$(AC) import -d $(PRODOS_IMAGE) --raw --stdin -t $(FTYPE_SYS) -a 0x2000 -n SCASM.SYSTEM < $(SCASM_BIN)
	$(AC) import -d $(PRODOS_IMAGE) --raw --stdin -t $(FTYPE_BIN) -a 0x6600 -n SCASM.65816 < $(SCASM_65816_BIN)
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
	@echo "  clean       - Remove all build artifacts"
	@echo "  help        - Display this help message"
	@echo "  prodos-help - Display ProDOS disk targets"
	@echo ""
	@echo "Components:"
	@echo "  SCASM       - Main assembler binary"
	@echo "  SCASM.65816 - 65816 CPU extension"
	@echo "  B.IO.*      - Display driver binaries"
	@echo ""
	@echo "Requirements:"
	@echo "  - vasm assembler with SCASM syntax support"
	@echo "  - Command: vasm6502_scasm"
	@echo ""
	@echo "ProDOS Disk Requirements (for 'make disk'):"
	@echo "  - Java 21+ (for AppleCommander)"
	@echo "  - AppleCommander acx.jar in /usr/local/share/java/"
	@echo "  - Blank ProDOS disk in prodos/blank140k.dsk"
	@echo "  - Run ./download-prodos.sh to download blank disk"
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
