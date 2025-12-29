# ProDOS Disk Image Creation

This project can create bootable ProDOS disk images containing the S-C Macro Assembler.

## Prerequisites

### 1. Java Runtime
Required to run AppleCommander:
```bash
# Check if Java is installed
java -version

# On macOS, install with Homebrew if needed
brew install openjdk@21
```

### 2. AppleCommander
Install AppleCommander acx.jar to `/usr/local/share/java/`:
```bash
# Download from: https://github.com/AppleCommander/AppleCommander/releases
# Or if you have it locally:
sudo mkdir -p /usr/local/share/java
sudo cp path/to/acx.jar /usr/local/share/java/
```

### 3. Minimal ProDOS Disk Image
Create a minimal bootable ProDOS disk:

**Option A: Use the helper script (recommended)**
```bash
# Create minimal ProDOS disk (PRODOS only - for system files like SCASM)
./download-prodos.sh

# Or with BASIC.SYSTEM (for BASIC programs)
./download-prodos.sh --with-basic
```

The script will:
- Download ProDOS 2.4.3 from https://releases.prodos8.com
- Remove all files except PRODOS (boot file)
- Optionally keep BASIC.SYSTEM if requested
- Create `prodos/blank140k.po` (ProDOS order format)

**Option B: Manual download**
1. Visit https://prodos8.com/releases/
2. Download ProDOS 2.4.3 (or latest) disk image (.po format)
3. Use AppleCommander to remove unnecessary files
4. Keep only PRODOS (and optionally BASIC.SYSTEM)
5. Save as: `prodos/blank140k.po` (use .po extension)

**Note:** ProDOS 8 is freely available from https://prodos8.com and is maintained by the ProDOS 8 community.

## Building a Bootable Disk

Once prerequisites are set up:

```bash
# Build all components and create bootable disk
make disk
```

This creates `build/SCASM.po` containing:
- SCASM.SYSTEM - Main assembler (at $2000)
- SCASM.65816 - 65816 extension (at $6600)
- B.IO.TWO.E - Apple //e 80-column driver
- B.IO.STB80 - STB-80 driver
- B.IO.VIDEX - Videx Videoterm driver
- B.IO.ULTRA - Videx Ultraterm driver

## Customization

Override default paths:
```bash
# Use a different ProDOS template
make disk PRODOS_TEMPLATE=/path/to/my/blank.po

# Use a different AppleCommander jar
make disk ACX_JAR=/opt/tools/acx.jar

# Change output disk name
make disk PRODOS_IMAGE=build/MyDisk.po
```

## Disk Operations

```bash
# List disk contents
make prodos-list

# Show disk information
make prodos-info

# Show disk usage map
make prodos-map

# Show all ProDOS targets
make prodos-help
```

## Requirements Summary

- **Java 21+** - For AppleCommander
- **AppleCommander acx.jar** - In `/usr/local/share/java/` (default)
- **Blank ProDOS disk** - In `prodos/blank140k.po` (default)
  - Available from https://prodos8.com (free)
  - Use `./download-prodos.sh` to download automatically

## Reusable Include

The `prodos.mk` file is a reusable Makefile include that can be used in other Apple II projects:

```makefile
# In your Makefile:
include path/to/prodos.mk

# Then use targets like:
# make prodos-disk
# make prodos-add-bin FILE=mybinary NAME=MYFILE ADDR=0x2000
```
