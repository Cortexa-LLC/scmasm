# S-C Macro Assembler 3.0 - Modern Build

This project contains the source code for the S-C Macro Assembler 3.0, originally developed for the Apple II with ProDOS. The sources have been fetched from the [original website](https://www.txbobsc.com/scsc/scassembler/index.html) and adapted for building with modern assemblers.

## Overview

The S-C Macro Assembler 3.0 (unreleased version, November 1990) is a powerful macro assembler that was used to assemble itself and various Applied Engineering projects.

## Project Structure

```
.
├── ASM1/           # General assembler core (part 1)
├── ASM2/           # General assembler core (part 2)
├── ASM65816/       # 6502/65C02/65816 CPU support
├── ASM6811/        # Motorola 6811 cross-assembler
├── SCI/            # S-C ProDOS Interface
├── build/          # Build output directory
├── fetch_sources.py  # Script to download sources
└── Makefile        # Build system
```

## Components

### General Assembler (ASM1/ASM2)
28 files forming the core assembler:
- Loader & Parameters
- Editor Functions
- Assembly Core Engine
- Symbol Table Management
- Macro Support
- Directive Processing
- Disk Operations

### 80-Column Display Drivers (ASM1)
- `IO.STANDARD` - Standard 40-column display
- `IO.TWO.E` - Apple //e 80-column card
- `IO.STB80` - STB-80 card
- `IO.VIDEX` - Videx Videoterm
- `IO.ULTRA` - Videx Ultraterm

### CPU Support (ASM65816)
7 files providing runtime-switchable CPU support via the `.OP` directive:
- 6502 processor (default)
- 65C02 processor
- Rockwell R65C02 (if ROCKWELL=1 at build time)
- 65802 processor
- 65816 processor
- Sweet-16 interpreter (if SWEET.16=1 at build time)

**Important:** The ASM65816 module builds an assembler that supports ALL these CPU variants simultaneously. You select which CPU you're targeting at assembly-time using the `.OP` directive in your source code, not at build-time.

### ProDOS Interface (SCI)
13 files providing:
- File operations
- System integration
- Error handling
- ProDOS MLI interface

## Building

### Prerequisites

You need `vasm` with SCASM syntax support:
```bash
# Check if vasm is available
which vasm6502_oldstyle
```

If not installed, you can build vasm from source:
```bash
# Clone vasm
git clone https://github.com/laubzega/vasm.git
cd vasm
make CPU=6502 SYNTAX=oldstyle
```

### Build Commands

```bash
# Build everything
make

# Build specific targets
make build/SCASM              # Main assembler
make build/SCASM.65816        # 65816 extension
make build/B.IO.TWO.E         # Apple //e driver

# Clean build artifacts
make clean

# Show help
make help

# List all source files
make list-sources
```

## Memory Map

From the original Apple II system:

| Address Range | Execution | Description |
|---------------|-----------|-------------|
| $2000-$21FF   | -         | Loader |
| $2200-$4AFF   | $8000-$A8FF | S-C Macro Assembler with 40-col driver |
| -             | $A900-$A9FF | Additional space for longer drivers |
| $4B00-$5FFF   | $AA00-$BEFF | S-C ProDOS Interface |
| $6000-$60FF   | $A800-$A8FF | //E 80-column driver |
| $6100-$61FF   | $A800-$A8FF | STB80 driver |
| $6200-$63FF   | $A800-$A9FF | Videx Videoterm driver |
| $6400-$65FF   | $A800-$A9FF | Videx Ultraterm driver |
| $6600-$71FF   | $D400-$DFFF | ASM Particular (CPU specific) |

## File Naming

All source files use the `.s` extension for compatibility with modern toolchains. The original Apple II files had no extension or used ProDOS-style naming.

## Original Build Process

The original Apple II build process used:
1. Assembly via control files (*.ACF)
2. BLOAD binary outputs into specific memory locations
3. BSAVE as SCASM.SYSTEM for ProDOS execution

This modern build uses vasm to directly produce binaries that match the original memory layout.

## Using the Assembler

### CPU Selection with the .OP Directive

The assembler starts in 6502 mode by default. Use the `.OP` directive to switch CPU targets:

```assembly
        .OP 6502        ; Base 6502 (default)
        .OP 65C02       ; 65C02 with additional opcodes
        .OP R65C02      ; Rockwell 65C02 (if built with ROCKWELL=1)
        .OP 65816       ; 65816/65802 with full instruction set
        .OP SWEET16     ; Sweet-16 interpreter (if built with SWEET.16=1)
```

**Example:**
```assembly
1000        .OP 65C02    ; Switch to 65C02 mode
1010        STZ $C000    ; 65C02-specific opcode
1020        PHX          ; Push X (65C02)
1030        PLY          ; Pull Y (65C02)
```

The `.OP` directive can be used multiple times in your source to switch between CPU types as needed.

### Build-Time Configuration

The ASM65816/X.ACF control file has these configuration options:

```assembly
ROCKWELL   .EQ 1    ; 0 = exclude Rockwell R65C02 opcodes (RMB, SMB, BBR, BBS)
SWEET.16   .EQ 1    ; 0 = exclude Sweet-16 interpreter support
AUXMEM     .EQ 1    ; 1 = use auxiliary memory for symbol table
```

Modify these values in ASM65816/X.ACF.s before building to customize which CPU variants are included.

## Refreshing Sources

To re-download all source files from the website:
```bash
python3 fetch_sources.py
```

This will fetch all 60 source files from https://www.txbobsc.com/scsc/scassembler/

## License

This is unreleased source code from 1990. The original authors are the S-C Software Corporation. This repository is for historical preservation and educational purposes.

## Credits

- Original S-C Macro Assembler: S-C Software Corporation
- Source hosting: Bob Sander-Cederlof (txbobsc.com)
- Modern build system: 2025
