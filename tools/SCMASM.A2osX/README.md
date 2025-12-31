# A2osX Macro Assembler (ASM.S)

This directory tests Remy Gibert's command-line batch assembler from the A2osX project.

## Purpose

This test validates that our S-C MASM 3.1 build can assemble A2osX's ASM.S source code, which:
1. Validates that our SCMASM implementation is complete and correct
2. Tests compatibility with A2osX assembly code
3. Demonstrates real-world usage of SCMASM directives

## Getting Started

Run the download script to fetch the latest A2osX sources:

```bash
./download-a2osx.sh
```

This will:
- Download ASM.S and all dependencies from GitHub
- Clean Apple II editor commands from source files
- Prepare files for testing with vasm-scmasm

## Files (after running download script)

- **ASM.S** - Original source file (from A2osX BIN/ASM.S.txt)
- **ASM.S.clean** - Same file with Apple II editor commands removed
- **inc/** - A2osX include files (macros, MLI definitions, etc.)
- **usr/src/bin/** - A2osX assembler module sources

## Source

All files downloaded from: https://github.com/A2osX/A2osX
- Main: BIN/ASM.S.txt
- Modules: BIN/ASM.S.*.txt
- Includes: INC/*.I.txt

## Dependencies

ASM.S requires these A2osX include files:
- inc/macros.i - A2osX standard macros
- inc/a2osx.i - A2osX system definitions
- inc/mli.i - ProDOS MLI interface
- inc/mli.e.i - ProDOS MLI error codes

And these assembler modules:
- usr/src/bin/asm.s.core - Core assembler engine
- usr/src/bin/asm.s.dir - Directive handlers
- usr/src/bin/asm.s.exp - Expression evaluator
- usr/src/bin/asm.s.fio - File I/O
- usr/src/bin/asm.s.mac - Macro processor
- usr/src/bin/asm.s.out - Output generation
- usr/src/bin/asm.s.src - Source handling
- usr/src/bin/asm.s.sym - Symbol table

## Features

ASM.S is a command-line assembler that supports:
- Multiple CPU types (6502, 65C02, 65816, Z80, Sweet-16)
- Batch assembly for build automation
- Command-line options: `-L` (list control), `-T <file>` (target file)
- All standard S-C MASM directives plus A2osX extensions

## Next Steps

1. Try assembling with vasm_scasm
2. Document any compatibility issues
3. If successful, integrate into build system
