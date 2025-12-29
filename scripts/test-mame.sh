#!/bin/bash
# Test SCMASM disk image with MAME Apple IIe Enhanced

DISK_IMAGE="${1:-build/SCMASM.po}"

if [ ! -f "$DISK_IMAGE" ]; then
    echo "Error: Disk image not found: $DISK_IMAGE"
    echo "Usage: $0 [disk-image.po]"
    exit 1
fi

echo "Testing $DISK_IMAGE with MAME Apple IIe Enhanced..."
echo "Press Ctrl-C to exit MAME"
echo ""

# Run MAME with Apple IIe Enhanced and our disk image
# -apple2ee = Apple IIe Enhanced
# -flop1 = Floppy drive 1
# -window = Run in window mode (not fullscreen)
# -skip_gameinfo = Skip the game info screen
mame apple2ee \
    -flop1 "$DISK_IMAGE" \
    -window \
    -skip_gameinfo
