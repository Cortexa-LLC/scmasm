# Testing SCMASM with MAME Apple IIe Enhanced

This guide explains how to set up and test the S-C Macro Assembler with the MAME emulator.

## Prerequisites

### 1. Install MAME

```bash
# On macOS with Homebrew
brew install mame

# Verify installation
mame -version
```

### 2. Set Up Apple IIe Enhanced ROMs

MAME requires authentic Apple IIe ROM files to emulate the hardware. You can obtain these from:

1. **Your own Apple IIe hardware** (legal dumping)
2. **Virtual ][ installation** (if you already have it)
3. **MAME ROM sets** (from legal sources)

#### Quick Setup Script

Run the provided setup script:

```bash
./scripts/setup-mame-roms.sh
```

This will:
- Copy Enhanced ROMs from Virtual ][ if available
- Create the required ROM directory structure
- Display which ROMs are still needed

#### Required ROM Files

MAME needs these ROM files in the `roms/` directory:

**Apple IIe Enhanced System ROMs:**
```
roms/apple2ee/342-0265-a.chr        # Video ROM (4,096 bytes)
roms/apple2ee/342-0304-a.e10        # CD ROM (8,192 bytes)
roms/apple2ee/342-0303-a.e8         # EF ROM (8,192 bytes)
roms/apple2ee/341-0132-d.e12        # Keyboard ROM (2,048 bytes)
```

**Disk II Controller ROMs:**
```
roms/a2diskiing/341-0027-a.p5       # P5 ROM (256 bytes)
roms/d2fdc/341-0028-a.rom           # P6 ROM (256 bytes)
```

**Optional - Votrax Speech Synthesizer:**
```
roms/votrsc01a/sc01a.bin            # Speech ROM (512 bytes)
```

#### ROM Sources

The setup process downloads ROMs from these community-maintained archives:

- **Keyboard ROM**: [ReactiveMicro Downloads](https://downloads.reactivemicro.com/Apple%20II%20Items/ROM_and_JEDEC/IIe/Keyboard%20ROM/)
  - File: Apple IIe Keyboard - 342-0132-D - 2716.bin

- **Disk II ROMs**: [Apple II Documentation Project](https://mirrors.apple2.org.za/Apple%20II%20Documentation%20Project/Interface%20Cards/Disk%20Drive%20Controllers/Apple%20Disk%20II%20Interface%20Card/ROM%20Images/)
  - P5: Apple Disk II 16 Sector Interface Card ROM P5 - 341-0027.bin
  - P6: Apple Disk II 16 Sector Interface Card ROM P6 - 341-0028.bin

- **Votrax ROM**: [mdk.cab MAME Collection](https://mdk.cab/game/votrsc01a)
  - File: votrsc01a.zip containing sc01a.bin

**Note**: These ROM images are archived for historical preservation. Apple IIe ROMs remain copyrighted by Apple. For legal emulation, you should dump ROMs from hardware you own.

#### Manual ROM Installation

If you prefer to install ROMs manually or from Virtual ][:

```bash
# Create ROM directories
mkdir -p roms/{apple2ee,apple2e,a2diskiing,d2fdc,votrsc01a}

# If you have Virtual ][ installed, copy the Enhanced ROMs:
cp ~/Library/Application\ Support/Virtual\ \]\[/ROM/Apple\ IIe\ Video\ -\ Enhanced\ -\ 342-0265-A\ -\ 2732.bin \
   roms/apple2ee/342-0265-a.chr

cp ~/Library/Application\ Support/Virtual\ \]\[/ROM/Apple\ IIe\ CD\ Enhanced\ -\ 342-0304-A\ -\ 2764.bin \
   roms/apple2ee/342-0304-a.e10

cp ~/Library/Application\ Support/Virtual\ \]\[/ROM/Apple\ IIe\ EF\ Enhanced\ -\ 342-0303-A\ -\ 2764.bin \
   roms/apple2ee/342-0303-a.e8
```

## Building and Testing

### 1. Build the Bootable Disk

```bash
# Download ProDOS template (one-time setup)
./scripts/download-prodos.sh

# Build everything and create bootable disk
make disk
```

This creates `build/SCMASM.po` - a bootable 140KB ProDOS disk image.

### 2. Test with MAME

```bash
# Run SCMASM in MAME Apple IIe Enhanced
./scripts/test-mame.sh

# Or manually:
mame apple2ee -flop1 build/SCMASM.po -window -skip_gameinfo
```

### 3. MAME Controls

- **F12**: Capture screenshots
- **Tab**: Open MAME menu
- **F3**: Reset Apple IIe
- **Esc**: Exit MAME (hold for a moment)
- **Scroll Lock**: Toggle keyboard capture
- **Ctrl+Left/Right**: Adjust emulation speed

### 4. Expected Boot Sequence

1. ProDOS 2.4.3 boots
2. SCMASM loader displays driver selection menu:
   ```
   S-C MACRO ASSEMBLER 3.1 (PRODOS)

   1 -- STANDARD 40-COLUMN
   2 -- VIDEX VIDEOTERM
   3 -- VIDEX ULTRATERM
   4 -- STB-80

   WHICH?
   ```
3. Select display driver (typically `1` for Enhanced IIe)
4. SCMASM starts at $8000

## Disk Image Contents

The `build/SCMASM.po` disk contains:

```
PRODOS          SYS  34 blocks  - ProDOS 2.4.3 operating system
SCMASM.SYSTEM   SYS  34 blocks  - Main assembler (loads at $2000)
SCMASM.65816    BIN   7 blocks  - 65816 extension (loads at $6600)
B.IO.TWO.E      BIN  50 blocks  - Apple //e 80-column driver
B.IO.STB80      BIN   1 block   - STB-80 driver
B.IO.VIDEX      BIN   1 block   - Videx Videoterm driver
B.IO.ULTRA      BIN   1 block   - Videx Ultraterm driver
```

## Memory Map

When SCMASM.SYSTEM loads and runs:

| Address Range | Purpose |
|---------------|---------|
| $2000-$21FF   | Loader code |
| $2200-$4AFF   | Main assembler (stored here, runs at $8000-$A8FF) |
| $4B00-$5FFF   | ProDOS Interface (stored here, runs at $AA00-$BEFF) |
| $6000-$65FF   | Selected display driver (runtime loaded) |
| $6600-$71FF   | 65816 CPU extension (runtime loaded) |

## Troubleshooting

### "Required files are missing"

MAME can't find the ROM files. Run `./scripts/setup-mame-roms.sh` and ensure all required ROMs are in the `roms/` directory.

### "Disk not recognized"

Ensure the disk image is in ProDOS order format (`.po` extension). Our build system creates the correct format.

### SCMASM doesn't boot

If ProDOS boots but SCMASM doesn't start:
1. Check that `SCMASM.SYSTEM` is on the disk: `make prodos-list`
2. Verify the file size is ~16KB
3. Try booting in a different Apple II emulator to compare behavior

### Display issues

- The Enhanced IIe should use option `1` (standard 40-column) or have 80-column automatically detected
- Other driver options are for third-party hardware cards

## Alternative Emulators

If MAME doesn't work, try these Apple II emulators:

- **Virtual ][** (macOS) - Native Mac app, excellent compatibility
- **AppleWin** (Windows) - Very accurate, ProDOS support
- **GSplus** (Multi-platform) - Apple IIgs emulator, runs IIe software
- **MicroM8** (Multi-platform) - Modern, fast, good debugger

All can use the `build/SCMASM.po` disk image directly.

## Clean Up

```bash
# Remove built binaries and disk image
make clean

# Remove downloaded ProDOS template
rm -rf prodos/

# Remove MAME ROMs (if desired)
rm -rf roms/
```

## References

- [MAME Apple II Documentation](https://docs.mamedev.org/)
- [ProDOS 8 Project](https://prodos8.com/)
- [Apple II Documentation Project](https://www.apple2.org.za/)
- [ReactiveMicro Apple II Wiki](https://wiki.reactivemicro.com/)
