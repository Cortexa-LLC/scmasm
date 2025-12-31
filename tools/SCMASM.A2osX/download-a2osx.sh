#!/bin/bash
# Download and prepare A2osX ASM.S for testing SCMASM compatibility
# This script fetches Remy Gibert's A2osX assembler source from GitHub
# and preprocesses it for use with vasm-scmasm

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_BASE="https://raw.githubusercontent.com/A2osX/A2osX/master"

echo "=========================================="
echo "A2osX ASM.S Download and Preparation"
echo "=========================================="
echo ""

# Download main ASM.S
echo "Downloading ASM.S..."
curl -sS "$GITHUB_BASE/BIN/ASM.S.txt" -o "$SCRIPT_DIR/ASM.S"

# Download includes
echo "Downloading includes..."
mkdir -p "$SCRIPT_DIR/inc"
curl -sS "$GITHUB_BASE/INC/MACROS.I.txt" -o "$SCRIPT_DIR/inc/macros.i"
curl -sS "$GITHUB_BASE/INC/A2OSX.I.txt" -o "$SCRIPT_DIR/inc/a2osx.i"
curl -sS "$GITHUB_BASE/INC/MLI.I.txt" -o "$SCRIPT_DIR/inc/mli.i"
curl -sS "$GITHUB_BASE/INC/MLI.E.I.txt" -o "$SCRIPT_DIR/inc/mli.e.i"

# Download source modules
echo "Downloading source modules..."
mkdir -p "$SCRIPT_DIR/usr/src/bin"
for module in core dir exp fio mac out src sym; do
    echo "  - asm.s.$module"
    curl -sS "$GITHUB_BASE/BIN/ASM.S.$module.txt" -o "$SCRIPT_DIR/usr/src/bin/asm.s.$module"
done

echo ""
echo "✓ Download complete"
echo ""

# Clean Apple II editor commands
echo "Cleaning Apple II editor commands..."
python3 - <<'PYTHON_SCRIPT'
import os
import sys

script_dir = os.path.dirname(os.path.abspath(__file__))

def clean_file(filepath):
    """Remove Apple II editor commands from source file."""
    with open(filepath, 'r') as f:
        lines = f.readlines()

    cleaned = []
    removed = 0

    for line in lines:
        # Remove non-printable characters (except newline and tab)
        line_clean = ''.join(c for c in line if c >= ' ' or c == '\n' or c == '\t')
        stripped = line_clean.strip()

        # Skip Apple II editor commands
        if stripped in ['NEW', 'AUTO', 'MAN', 'ASM', 'LOAD', 'SAVE']:
            removed += 1
            continue
        if stripped.startswith('AUTO ') or stripped.startswith('SAVE ') or stripped.startswith('LOAD '):
            removed += 1
            continue

        cleaned.append(line_clean)

    return cleaned, removed

# Clean main file
asm_file = os.path.join(script_dir, 'ASM.S')
asm_clean = os.path.join(script_dir, 'ASM.S.clean')

cleaned_lines, removed = clean_file(asm_file)
with open(asm_clean, 'w') as f:
    f.writelines(cleaned_lines)

print(f"  ASM.S: removed {removed} editor command lines")

# Clean all module files
usr_dir = os.path.join(script_dir, 'usr/src/bin')
total_removed = removed

for filename in os.listdir(usr_dir):
    if filename.startswith('asm.s.'):
        filepath = os.path.join(usr_dir, filename)
        cleaned_lines, removed = clean_file(filepath)

        # Write back to same file (in-place cleaning)
        with open(filepath, 'w') as f:
            f.writelines(cleaned_lines)

        if removed > 0:
            print(f"  {filename}: removed {removed} editor command lines")
        total_removed += removed

print(f"\n✓ Cleaned {total_removed} total lines")
PYTHON_SCRIPT

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Files downloaded to: $SCRIPT_DIR"
echo "  ASM.S        - Original source"
echo "  ASM.S.clean  - Cleaned for vasm"
echo "  inc/         - A2osX includes"
echo "  usr/src/bin/ - Assembly modules"
echo ""
echo "To test with vasm:"
echo "  cd $SCRIPT_DIR"
echo "  vasm6502_scmasm -Fbin -o /tmp/asm ASM.S.clean"
echo ""
