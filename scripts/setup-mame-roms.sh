#!/bin/bash
# Setup Apple IIe Enhanced ROMs for MAME

echo "Setting up Apple IIe Enhanced ROMs for MAME..."
echo ""

ROMS_DIR="roms"
V2_ROM_DIR=~/"Library/Application Support/Virtual ][/ROM"

# Create ROM directories
mkdir -p "$ROMS_DIR/apple2ee"
mkdir -p "$ROMS_DIR/apple2e"
mkdir -p "$ROMS_DIR/a2diskiing"
mkdir -p "$ROMS_DIR/d2fdc"
mkdir -p "$ROMS_DIR/votrsc01a"

# Copy ROMs from Virtual ][ if available
if [ -d "$V2_ROM_DIR" ]; then
    echo "Found Virtual ][ ROMs, copying Enhanced ROMs..."

    # Apple IIe Enhanced ROMs
    if [ -f "$V2_ROM_DIR/Apple IIe Video - Enhanced - 342-0265-A - 2732.bin" ]; then
        cp "$V2_ROM_DIR/Apple IIe Video - Enhanced - 342-0265-A - 2732.bin" \
           "$ROMS_DIR/apple2ee/342-0265-a.chr"
        echo "  ✓ Video ROM (342-0265-a.chr)"
    fi

    if [ -f "$V2_ROM_DIR/Apple IIe CD Enhanced - 342-0304-A - 2764.bin" ]; then
        cp "$V2_ROM_DIR/Apple IIe CD Enhanced - 342-0304-A - 2764.bin" \
           "$ROMS_DIR/apple2ee/342-0304-a.e10"
        echo "  ✓ CD ROM (342-0304-a.e10)"
    fi

    if [ -f "$V2_ROM_DIR/Apple IIe EF Enhanced - 342-0303-A - 2764.bin" ]; then
        cp "$V2_ROM_DIR/Apple IIe EF Enhanced - 342-0303-A - 2764.bin" \
           "$ROMS_DIR/apple2ee/342-0303-a.e8"
        echo "  ✓ EF ROM (342-0303-a.e8)"
    fi

    echo ""
fi

echo "Missing ROMs (required):"
echo ""
echo "  Keyboard ROM:"
echo "    $ROMS_DIR/apple2ee/341-0132-d.e12 (2048 bytes)"
echo "    OR"
echo "    $ROMS_DIR/apple2e/342-0132-c.e12 (2048 bytes)"
echo ""
echo "  Disk II Controller:"
echo "    $ROMS_DIR/a2diskiing/341-0027-a.p5 (256 bytes)"
echo ""
echo "  Disk II Drive Controller:"
echo "    $ROMS_DIR/d2fdc/341-0028-a.rom (256 bytes)"
echo ""
echo "Optional ROMs:"
echo "  Speech Chip:"
echo "    $ROMS_DIR/votrsc01a/sc01a.bin (2048 bytes)"
echo ""
echo "========================================="
echo "How to obtain missing ROMs:"
echo "========================================="
echo ""
echo "1. Extract from MAME ROM sets (legally obtained)"
echo "2. Dump from your own Apple IIe hardware"
echo "3. Search for 'apple2ee MAME ROMs' online"
echo ""
echo "Once you have the ROM files, place them in the appropriate"
echo "directories listed above, then run ./test-mame.sh"
echo ""
