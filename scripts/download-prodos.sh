#!/bin/bash
# Download and create minimal ProDOS bootable disk image
# ProDOS 8 is freely available from https://prodos8.com

set -e

PRODOS_DIR="prodos"
PRODOS_URL="https://releases.prodos8.com/ProDOS_2_4_3.po"
PRODOS_TEMP="$PRODOS_DIR/prodos-download.po"
PRODOS_FILE="$PRODOS_DIR/blank140k.po"
ACX_JAR="${ACX_JAR:-/usr/local/share/java/acx.jar}"
KEEP_BASIC=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --with-basic)
            KEEP_BASIC=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--with-basic]"
            echo ""
            echo "Download ProDOS and create a minimal bootable disk image."
            echo ""
            echo "Options:"
            echo "  --with-basic    Keep BASIC.SYSTEM (default: remove it)"
            echo "  --help          Show this help message"
            echo ""
            echo "Creates: $PRODOS_FILE"
            echo "  - Contains only PRODOS boot file (minimal)"
            echo "  - Optionally includes BASIC.SYSTEM with --with-basic"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "Creating minimal ProDOS bootable disk image..."
echo "Source: ProDOS 8 (https://prodos8.com)"
echo ""

# Check for AppleCommander
if [ ! -f "$ACX_JAR" ]; then
    echo "ERROR: AppleCommander not found at $ACX_JAR"
    echo ""
    echo "Please install AppleCommander acx.jar:"
    echo "  sudo mkdir -p /usr/local/share/java"
    echo "  sudo cp path/to/acx.jar /usr/local/share/java/"
    echo ""
    echo "Or set ACX_JAR environment variable to its location."
    exit 1
fi

# Check for Java
if ! command -v java &> /dev/null; then
    echo "ERROR: Java not found. AppleCommander requires Java 21+."
    echo ""
    echo "Install Java:"
    echo "  brew install openjdk@21"
    exit 1
fi

# Create directory if it doesn't exist
mkdir -p "$PRODOS_DIR"

# Download ProDOS disk image
if command -v curl &> /dev/null; then
    echo "Downloading ProDOS 2.4.3..."
    # Note: -k bypasses SSL certificate verification for releases.prodos8.com (trusted source)
    curl -k -L -o "$PRODOS_TEMP" "$PRODOS_URL" || {
        echo "ERROR: Failed to download from $PRODOS_URL"
        echo ""
        echo "Please manually download a ProDOS disk image from:"
        echo "  https://prodos8.com/releases/"
        echo ""
        echo "Save it as: $PRODOS_TEMP"
        exit 1
    }
elif command -v wget &> /dev/null; then
    echo "Downloading ProDOS 2.4.3..."
    # Note: --no-check-certificate bypasses SSL verification for releases.prodos8.com (trusted source)
    wget --no-check-certificate -O "$PRODOS_TEMP" "$PRODOS_URL" || {
        echo "ERROR: Failed to download from $PRODOS_URL"
        echo ""
        echo "Please manually download a ProDOS disk image from:"
        echo "  https://prodos8.com/releases/"
        echo ""
        echo "Save it as: $PRODOS_TEMP"
        exit 1
    }
else
    echo "ERROR: Neither curl nor wget found."
    echo ""
    echo "Please manually download a ProDOS disk image from:"
    echo "  https://prodos8.com/releases/"
    echo ""
    echo "Save it as: $PRODOS_TEMP"
    exit 1
fi

echo "Creating minimal bootable disk..."
echo ""

# Copy downloaded disk to final location
cp "$PRODOS_TEMP" "$PRODOS_FILE"

# Get list of files and delete everything except PRODOS and optionally BASIC.SYSTEM
echo "Removing unnecessary files..."
java -jar "$ACX_JAR" list -d "$PRODOS_FILE" | grep -E "^  [^ ]" | while read -r line; do
    # Extract filename (first field)
    filename=$(echo "$line" | awk '{print $1}')

    # Skip if it's PRODOS
    if [ "$filename" = "PRODOS" ]; then
        echo "  Keeping: PRODOS (boot file)"
        continue
    fi

    # Skip BASIC.SYSTEM if --with-basic flag is set
    if [ "$KEEP_BASIC" = true ] && [ "$filename" = "BASIC.SYSTEM" ]; then
        echo "  Keeping: BASIC.SYSTEM (requested)"
        continue
    fi

    # Delete the file
    echo "  Removing: $filename"
    java -jar "$ACX_JAR" delete -d "$PRODOS_FILE" "$filename" 2>/dev/null || true
done

# Clean up temp file
rm -f "$PRODOS_TEMP"

# Show final disk contents
echo ""
echo "✓ Minimal ProDOS disk image created successfully!"
echo "  Location: $PRODOS_FILE"
SIZE=$(ls -lh "$PRODOS_FILE" | awk '{print $5}')
echo "  Size: $SIZE"
echo ""
echo "Contents:"
java -jar "$ACX_JAR" list -d "$PRODOS_FILE"
echo ""
echo "You can now run: make disk"
