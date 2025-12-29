# S-C Macro Assembler 3.1 - Modernized Build System

This project contains the source code for Bob Sander-Cederlof's S-C Macro Assembler, originally developed for the Apple II with ProDOS. The sources have been fetched from the [original website](https://www.txbobsc.com/scsc/scassembler/index.html) and modernized with a cross-platform build system using [vasm-ext](https://github.com/Cortexa-LLC/vasm-ext) for SCASM syntax support.

**Key Features:**
- **Cross-platform development**: Build on modern macOS, Linux, or Windows systems
- **Target vintage hardware**: Produces authentic Apple II ProDOS executables
- **Bootable disk images**: Automated ProDOS disk image creation with AppleCommander
- **Modern tooling**: Uses vasm cross-assembler with SCASM syntax extensions

## Overview

The S-C Macro Assembler 3.1 is a powerful macro assembler that was used to assemble itself and various Applied Engineering projects. This version includes the CS/CZ directives and has been updated to build with contemporary development tools while maintaining full compatibility with the original Apple II assembly language.

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

**Required:**
- **vasm with SCASM syntax**: Use [vasm-ext](https://github.com/Cortexa-LLC/vasm-ext) which adds SCASM syntax support to vasm
  ```bash
  # Check if vasm is available
  which vasm6502_scasm
  ```

**Optional (for bootable disk images):**
- **Java 21+**: Required for AppleCommander
- **AppleCommander acx.jar**: For ProDOS disk operations
- **ProDOS disk template**: Downloaded automatically via `./scripts/download-prodos.sh`

See [README-PRODOS.md](README-PRODOS.md) for complete ProDOS disk image setup instructions.

### Build Commands

```bash
# Build all components
make

# Build specific targets
make build/SCMASM             # Main assembler
make build/SCMASM.65816       # 65816 extension
make build/B.IO.TWO.E         # Apple //e driver

# Create bootable ProDOS disk image
./scripts/download-prodos.sh          # One-time setup: download ProDOS template
make disk                     # Build and create SCMASM.po disk image

# Clean build artifacts
make clean

# Show help
make help
make prodos-help              # Show ProDOS disk targets

# List all source files
make list-sources
```

### Output Files

The build produces authentic Apple II binaries that can run on:
- **Real Apple II hardware** with ProDOS
- **Emulators**: AppleWin, MAME, GSplus, OpenEmulator, etc.
- **Disk image**: `build/SCMASM.po` - Bootable 140KB ProDOS disk

**Generated files:**
```
build/
├── SCMASM         # Main assembler (ProDOS SYS file, loads at $2000)
├── SCMASM.65816   # 65816 extension (loads at $6600)
├── B.IO.TWO.E     # Apple //e 80-column driver
├── B.IO.STB80     # STB-80 driver
├── B.IO.VIDEX     # Videx Videoterm driver
├── B.IO.ULTRA     # Videx Ultraterm driver
└── SCMASM.po      # Bootable ProDOS disk image (if 'make disk' run)
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
3. BSAVE as SCMASM.SYSTEM for ProDOS execution

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
python3 scripts/fetch_sources.py
```

This will fetch all 60 source files from https://www.txbobsc.com/scsc/scassembler/

## License

This is source code from 1990-1991. The original authors are the S-C Software Corporation. This repository is for historical preservation and educational purposes.

## Credits

- **Original S-C Macro Assembler**: Bob Sander-Cederlof & S-C Software Corporation
- **Source hosting**: Bob Sander-Cederlof ([txbobsc.com](https://www.txbobsc.com/scsc/scassembler/index.html))
- **Modern build system**: Cortexa LLC (2025)
- **SCASM syntax support**: [vasm-ext](https://github.com/Cortexa-LLC/vasm-ext) - vasm with SCASM syntax extensions

## Related Projects

- **[vasm-ext](https://github.com/Cortexa-LLC/vasm-ext)** - vasm cross-assembler with SCASM syntax support
- **[AppleCommander](https://github.com/AppleCommander/AppleCommander)** - ProDOS disk image utilities
- **[ProDOS 8](https://prodos8.com)** - Modern ProDOS distribution
