# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the S-C Macro Assembler 3.0 - a powerful macro assembler originally developed for the Apple II with ProDOS. The source code has been fetched from the original website and adapted for modern assemblers. The project produces several binary outputs including the main assembler, a 65816 CPU extension, and various display drivers for different Apple II hardware configurations.

## Build Commands

All builds require `vasm6502_scasm` (vasm with SCASM syntax support). If not available, build from source: `git clone https://github.com/laubzega/vasm.git && cd vasm && make CPU=6502 SYNTAX=oldstyle`.

```bash
# Build all components (main assembler, 65816 extension, display drivers)
make

# Build specific targets
make build/SCMASM             # Main assembler
make build/SCMASM.65816       # 65816 CPU support extension
make build/B.IO.TWO.E         # Apple //e 80-column driver
make build/B.IO.STB80         # STB-80 driver
make build/B.IO.VIDEX         # Videx Videoterm driver
make build/B.IO.ULTRA         # Videx Ultraterm driver

# Clean build artifacts
make clean

# List all source files in build order
make list-sources
```

## Architecture

The assembler is built from multiple modules that are linked together in a specific order:

### Loader & Core (ASM2)
- **SC.LOADER.s** - Program entry point and initialization
- **X.DATA.s** - Global data structures and workspace
- **X.PARAMETERS.s** - Configuration and memory layout parameters

### Editor & User Interface (ASM2)
- **X.EDIT.s** - Main editor functionality
- **X.EDIT.LINES.s** - Line-based editing operations
- **X.MISC.COMMANDS.s** - Miscellaneous user commands
- **X.SEARCH.COMMA.s** - Search functionality
- **X.TEXT.SEARCH.s** - Text search operations
- **X.FIND.AND.REP.s** - Find and replace operations
- **X.READ.LINE.s** - Input line reading

### Core Assembly Engine (ASM2)
- **X.OUTPUT.ROUTI.s** - Binary output generation
- **X.DISK.OPERATI.s** - Disk file I/O
- **X.PARSE.LINE.R.s** - Line parsing and tokenization
- **X.ASM.GENERAL.s** - Main assembly logic
- **X.ASM.NEXT.LINE.s** - Line-by-line assembly
- **X.EXPRESSION.C.s** - Expression evaluation

### Symbol Management (ASM2)
- **X.SYMBOL.TABLE.s** - Symbol table management
- **X.PRINT.SYMBOLS.s** - Symbol display and debugging

### Macro Support (ASM2)
- **X.MACRO.s** - Macro definition and expansion

### Directives (ASM2 & ASM1)
- **X.DIRECTIVES.1.s** - First set of assembly directives
- **X.DIRECTIVES.2.s** - Second set of assembly directives
- **X.AC.DIRECTIVE.s** - Control file directive processing
- **X.NEW.QUOTES.s** - Quote and string handling
- **X.TABLES.DIREC.s** - Directive lookup tables
- **X.ASM.VECTORS.s** - Assembly vector definitions
- **IO.STANDARD.s** - Standard 40-column display I/O

### CPU Support (ASM65816)
Optional extension module that adds support for multiple CPU variants via the `.OP` directive:
- **X.ASM.LINKAGE.s** - Linkage to main assembler
- **X.ASM.65816.1.s** & **X.ASM.65816.2.s** - 65816 opcode tables and assembly
- **X.TABLES.65816.s** - CPU variant lookup tables
- **X.OP.DIRECTIVE.s** - CPU selection via `.OP` directive
- **X.DATA.s** - CPU-specific data structures

Configuration flags in ASM65816/X.ACF.s control which CPU variants are included at build time:
- `ROCKWELL = 1` - Include Rockwell R65C02 opcodes (RMB, SMB, BBR, BBS)
- `SWEET.16 = 1` - Include Sweet-16 interpreter support
- `AUXMEM = 1` - Use auxiliary memory for symbol table (Apple //e feature)

### ProDOS Interface (SCI)
Optional file system interface for the Apple II ProDOS operating system (13 modules for file operations, MLI interface, error handling).

### Display Drivers (ASM1)
Each driver is independently assembled for different Apple II hardware:
- **IO.STANDARD.s** - 40-column display (included in main assembler)
- **IO.TWO.E.s** - Apple //e 80-column card
- **IO.STB80.s** - STB-80 80-column card
- **IO.VIDEX.s** - Videx Videoterm
- **IO.ULTRA.s** - Videx Ultraterm

## Key Concepts

### CPU Selection via .OP Directive
The assembler defaults to 6502 mode. The `.OP` directive switches CPU variants at assembly time (not build time). All CPU variants are compiled into SCMASM.65816 simultaneously:

```assembly
.OP 6502        ; Base 6502 (default)
.OP 65C02       ; 65C02 with additional opcodes
.OP R65C02      ; Rockwell 65C02 (requires ROCKWELL=1 at build time)
.OP 65816       ; 65816/65802 with full instruction set
.OP SWEET16     ; Sweet-16 interpreter (requires SWEET.16=1 at build time)
```

### Build Order and Dependencies
The Makefile uses control files (`X.ACF.s`) that specify include order. The main assembler (ASM1/X.ACF.s) includes files from both ASM1/ and ASM2/ in a specific sequence. The 65816 extension (ASM65816/X.ACF.s) is built separately and linked at runtime. This ordering is critical - changing file sequence will break assembly.

### Memory Layout
The original Apple II memory map is preserved in this build:
- $2000-$21FF: Loader
- $2200-$4AFF: Main assembler with 40-col driver
- $4B00-$5FFF: ProDOS Interface
- $6000-$71FF: Display drivers and CPU-specific modules

## Important Notes

- All source files use `.s` extension for modern toolchain compatibility (originally had no extension or ProDOS naming)
- The project is designed to be self-hosting - the assembler was built with itself and can assemble its own source code
- Display drivers (IO.*.s) are standalone modules that can be replaced to support different Apple II hardware configurations
- The 65816 extension is optional; SCMASM without it supports only 6502/65C02 opcodes
- Source files from https://www.txbobsc.com/scsc/scassembler/ can be refreshed with `python3 scripts/fetch_sources.py`
