#!/bin/bash
# Launch MAME with GDB stub for MCP debugging

cd "$(dirname "$0")/.."

echo "=== Launching MAME with GDB Stub ===="
echo ""
echo "GDB stub listening on localhost:2159"
echo ""
echo "IMPORTANT: MAME will start PAUSED in debug mode."
echo "To continue execution, either:"
echo "  1. Use MCP server: mame_continue()"
echo "  2. Connect with GDB and type: c"
echo "  3. Run: python3 scripts/mcp-continue.py"
echo ""
echo "Starting MAME..."
echo ""

# Start MAME in background
mame apple2ee \
    -debug \
    -debugger gdbstub \
    -debugger_port 2159 \
    -flop1 build/SCMASM.po \
    -window \
    -skip_gameinfo &

MAME_PID=$!
echo "MAME PID: $MAME_PID"
echo ""

# Wait for GDB stub to be ready
echo "Waiting for GDB stub to initialize..."
sleep 3

# Check if port is listening
if lsof -i :2159 | grep -q LISTEN; then
    echo "✓ GDB stub ready on port 2159"
    echo ""

    # Set breakpoints if requested
    if [ "$1" = "--break-loader" ]; then
        echo "Setting breakpoints for loader debugging..."
        python3 scripts/mcp-set-breakpoints.py --loader
        echo "✓ Breakpoints set"
        echo ""
        echo "MAME is PAUSED at start. Use mcp_continue() to begin."
        echo "Breakpoints:"
        echo "  - 0x2000: Loader entry"
        echo "  - 0x211E: MOVE routine"
    elif [ "$1" = "--continue" ] || [ -z "$1" ]; then
        echo "Sending continue command to start execution..."
        python3 scripts/mcp-continue.py
        echo "✓ MAME should now be running"
    else
        echo "MAME is PAUSED. Run 'python3 scripts/mcp-continue.py' to continue."
    fi
else
    echo "✗ GDB stub not ready"
fi

echo ""
echo "To stop MAME: kill $MAME_PID"
