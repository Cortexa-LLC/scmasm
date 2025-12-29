# MCP GDB Debugger for MAME

This MCP server allows Claude Code to debug SCMASM in MAME through the GDB remote stub interface.

## ⚠️ Current Status

### What Works
✅ **MCP Server**: Fully functional JSON-RPC 2.0 implementation
✅ **GDB Stub**: MAME's `-debugger gdbstub` starts and listens on port 2159
✅ **Initial Connection**: First connection succeeds and can send commands

### Known Issues
❌ **MAME GDB Stub Bug**: Connections are not properly closed by MAME, leaving them in CLOSE_WAIT state
❌ **No Reconnection**: After first connection closes, MAME refuses all new connections
❌ **MCP Incompatible**: MCP model (new connection per tool call) cannot work with this bug

### Root Cause
MAME's GDB stub for 6502/Apple IIe has a connection handling bug:
1. Initial connection works fine
2. When client closes connection, MAME doesn't properly close its end
3. Connection remains in CLOSE_WAIT state indefinitely
4. MAME refuses new connections while old connection is stuck
5. Only way to recover is to restart MAME

This is a **MAME bug**, not an MCP server issue. The MCP server design is correct, but MAME's GDB stub implementation prevents the connection model from working.

### Technical Details
**Test Results** (MAME 0.269, macOS):
```bash
# Launch MAME with GDB stub
./scripts/launch-mame-debug.sh --pause

# Check initial state
lsof -i :2159
# Output: TCP localhost:gdbremote (LISTEN) ✓

# Connect and send command
python3 -c "
sock = socket.connect(('localhost', 2159))
sock.send(b'\$g#67')  # Read registers
sock.close()
"

# Check state after close
lsof -i :2159
# Output: TCP localhost:gdbremote->localhost:60015 (CLOSE_WAIT) ✗
# Expected: TCP localhost:gdbremote (LISTEN)

# Try to reconnect
python3 -c "socket.connect(('localhost', 2159))"
# Result: [Errno 61] Connection refused ✗
```

The CLOSE_WAIT state indicates MAME received the client's FIN packet but never closed its own end of the connection, blocking all subsequent connections.

### Recommendation
**Use MAME's built-in ImGui debugger** (`-debugger imgui`) for reliable debugging.

The MCP server code is preserved in this repository as a reference implementation that will work once MAME's GDB stub bug is fixed in a future version.

## Quick Start

### 1. Launch MAME (Automatic Continue)

By default, MAME will start and automatically continue execution:

```bash
./scripts/launch-mame-debug.sh
```

The script will:
- Start MAME with GDB stub on port 2159
- Wait for GDB stub to initialize
- Automatically send "continue" command so MAME runs normally

### 2. Launch MAME with Breakpoints (For Debugging)

To debug the loader, use the `--break-loader` option:

```bash
./scripts/launch-mame-debug.sh --break-loader
```

This sets breakpoints at:
- `0x2000`: Loader entry point
- `0x211E`: MOVE routine
- `0x201C`: Second MOVE call

MAME will stay PAUSED. Use `python3 scripts/mcp-continue.py` or the MCP server to continue.

### 3. Test MCP Server

```bash
# Test initialization
echo '{"jsonrpc":"2.0","method":"initialize","id":1}' | python3 scripts/mcp-gdb-server.py

# Test connection
echo '{"jsonrpc":"2.0","method":"tools/call","id":1,"params":{"name":"mame_connect","arguments":{}}}' | python3 scripts/mcp-gdb-server.py
```

## Setup in Claude Code

### Option 1: MCP Configuration File

Create or edit `~/.config/claude-code/mcp.json`:

```json
{
  "mcpServers": {
    "mame-gdb-debugger": {
      "command": "python3",
      "args": ["/Users/bryanw/Projects/Vintage/tools/scasm/scripts/mcp-gdb-server.py"]
    }
  }
}
```

### Option 2: Claude Code Settings

1. Open Claude Code settings
2. Navigate to MCP Servers section
3. Add new server:
   - Name: `mame-gdb-debugger`
   - Command: `python3`
   - Args: `/Users/bryanw/Projects/Vintage/tools/scasm/scripts/mcp-gdb-server.py`

## Available Tools

Once connected, the following tools are available:

- `mame_connect()` - Connect to MAME GDB stub
- `mame_read_memory(address, length)` - Read memory at any address
- `mame_write_memory(address, data)` - Write memory at any address
- `mame_set_breakpoint(address)` - Set breakpoints
- `mame_continue()` - Continue execution
- `mame_step()` - Single step execution
- `mame_read_registers()` - Read CPU registers (A, X, Y, PC, SP, etc.)

## Example Debugging Session

```
1. Launch MAME with GDB stub:
   ./scripts/launch-mame-debug.sh

2. In Claude Code:
   - Connect: mame_connect()
   - Check loader memory: mame_read_memory(0x2000, 16)
   - Set breakpoint at MOVE: mame_set_breakpoint(0x211E)
   - Continue: mame_continue()
   - Check if copied to $8000: mame_read_memory(0x8000, 16)
```

## Troubleshooting

**"Connection refused"**
- Ensure MAME is running with `./scripts/launch-mame-debug.sh`
- Check MAME started with GDB stub on port 2159

**"MCP server not responding"**
- Test standalone: `echo '{"jsonrpc":"2.0","method":"initialize","id":1}' | python3 scripts/mcp-gdb-server.py`
- Check for Python errors in output

**"Tool not available in Claude Code"**
- Verify MCP server is added to Claude Code configuration
- Restart Claude Code after adding the server
- Check MCP server status in Claude Code settings
