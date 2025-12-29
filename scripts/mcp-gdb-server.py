#!/usr/bin/env python3
"""
MCP Server for MAME GDB Debugging

Provides Claude Code with tools to debug MAME through the GDB remote stub interface.
"""

import socket
import sys
import json


class MAMEGDBClient:
    """Client for MAME's GDB remote stub interface"""

    def __init__(self, host='localhost', port=2159):
        self.host = host
        self.port = port
        self.sock = None

    def connect(self):
        """Connect to MAME GDB stub"""
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.settimeout(5.0)
            self.sock.connect((self.host, self.port))
            return True, "Connected to MAME GDB stub"
        except Exception as e:
            return False, f"Connection failed: {e}"

    def send_command(self, cmd):
        """Send GDB remote protocol command"""
        if not self.sock:
            return None, "Not connected"

        try:
            # Calculate checksum
            checksum = sum(ord(c) for c in cmd) & 0xFF
            packet = f"${cmd}#{checksum:02x}"

            self.sock.sendall(packet.encode())

            # Read response
            response = b""
            while True:
                chunk = self.sock.recv(4096)
                if not chunk:
                    break
                response += chunk
                if b'#' in response:
                    break

            # Parse response
            if response.startswith(b'$'):
                end = response.find(b'#')
                if end > 0:
                    return True, response[1:end].decode()

            return False, f"Invalid response: {response}"

        except Exception as e:
            return False, f"Command failed: {e}"

    def read_memory(self, address, length):
        """Read memory at address"""
        cmd = f"m{address:x},{length:x}"
        success, data = self.send_command(cmd)

        if success and data:
            # Convert hex string to bytes
            try:
                bytes_data = bytes.fromhex(data)
                return True, bytes_data.hex(' ')
            except:
                return False, f"Failed to parse: {data}"

        return success, data

    def write_memory(self, address, data):
        """Write memory at address"""
        hex_data = ''.join(f'{b:02x}' for b in data)
        cmd = f"M{address:x},{len(data):x}:{hex_data}"
        return self.send_command(cmd)

    def set_breakpoint(self, address):
        """Set breakpoint at address"""
        cmd = f"Z0,{address:x},1"
        return self.send_command(cmd)

    def continue_execution(self):
        """Continue execution"""
        return self.send_command("c")

    def step(self):
        """Single step"""
        return self.send_command("s")

    def read_registers(self):
        """Read all registers"""
        return self.send_command("g")

    def disconnect(self):
        """Disconnect from MAME"""
        if self.sock:
            self.sock.close()
            self.sock = None


# MCP Protocol Implementation
def handle_mcp_request(request):
    """Handle MCP tool request"""

    tool = request.get('params', {}).get('name')
    args = request.get('params', {}).get('arguments', {})

    client = MAMEGDBClient()

    if tool == 'mame_connect':
        success, message = client.connect()
        return {
            "content": [
                {
                    "type": "text",
                    "text": message
                }
            ]
        }

    elif tool == 'mame_read_memory':
        address = args.get('address', 0)
        length = args.get('length', 16)

        # Connect first
        success, _ = client.connect()
        if not success:
            return {"content": [{"type": "text", "text": "Failed to connect"}]}

        success, data = client.read_memory(address, length)
        client.disconnect()

        return {
            "content": [
                {
                    "type": "text",
                    "text": f"Memory at ${address:04X}:\n{data}" if success else f"Error: {data}"
                }
            ]
        }

    elif tool == 'mame_write_memory':
        address = args.get('address', 0)
        data = args.get('data', [])

        success, _ = client.connect()
        if not success:
            return {"content": [{"type": "text", "text": "Failed to connect"}]}

        success, message = client.write_memory(address, bytes(data))
        client.disconnect()

        return {
            "content": [
                {
                    "type": "text",
                    "text": message if success else f"Error: {message}"
                }
            ]
        }

    elif tool == 'mame_set_breakpoint':
        address = args.get('address', 0)

        success, _ = client.connect()
        if not success:
            return {"content": [{"type": "text", "text": "Failed to connect"}]}

        success, message = client.set_breakpoint(address)
        client.disconnect()

        return {
            "content": [
                {
                    "type": "text",
                    "text": f"Breakpoint set at ${address:04X}" if success else f"Error: {message}"
                }
            ]
        }

    elif tool == 'mame_continue':
        success, _ = client.connect()
        if not success:
            return {"content": [{"type": "text", "text": "Failed to connect"}]}

        success, message = client.continue_execution()
        client.disconnect()

        return {"content": [{"type": "text", "text": "Continuing execution" if success else f"Error: {message}"}]}

    elif tool == 'mame_step':
        success, _ = client.connect()
        if not success:
            return {"content": [{"type": "text", "text": "Failed to connect"}]}

        success, message = client.step()
        client.disconnect()

        return {"content": [{"type": "text", "text": "Stepped" if success else f"Error: {message}"}]}

    elif tool == 'mame_read_registers':
        success, _ = client.connect()
        if not success:
            return {"content": [{"type": "text", "text": "Failed to connect"}]}

        success, data = client.read_registers()
        client.disconnect()

        return {"content": [{"type": "text", "text": f"Registers:\n{data}" if success else f"Error: {data}"}]}

    return {"content": [{"type": "text", "text": f"Unknown tool: {tool}"}]}


def main():
    """MCP server main loop"""

    # Send server info on startup
    server_info = {
        "jsonrpc": "2.0",
        "id": 1,
        "result": {
            "protocolVersion": "2024-11-05",
            "capabilities": {
                "tools": {}
            },
            "serverInfo": {
                "name": "mame-gdb-debugger",
                "version": "1.0.0"
            }
        }
    }

    # List available tools
    tools = {
        "jsonrpc": "2.0",
        "method": "tools/list",
        "result": {
            "tools": [
                {
                    "name": "mame_connect",
                    "description": "Connect to MAME GDB stub",
                    "inputSchema": {
                        "type": "object",
                        "properties": {}
                    }
                },
                {
                    "name": "mame_read_memory",
                    "description": "Read memory from MAME",
                    "inputSchema": {
                        "type": "object",
                        "properties": {
                            "address": {"type": "integer", "description": "Memory address (hex)"},
                            "length": {"type": "integer", "description": "Number of bytes to read"}
                        },
                        "required": ["address"]
                    }
                },
                {
                    "name": "mame_write_memory",
                    "description": "Write memory to MAME",
                    "inputSchema": {
                        "type": "object",
                        "properties": {
                            "address": {"type": "integer"},
                            "data": {"type": "array", "items": {"type": "integer"}}
                        },
                        "required": ["address", "data"]
                    }
                },
                {
                    "name": "mame_set_breakpoint",
                    "description": "Set breakpoint in MAME",
                    "inputSchema": {
                        "type": "object",
                        "properties": {
                            "address": {"type": "integer"}
                        },
                        "required": ["address"]
                    }
                },
                {
                    "name": "mame_continue",
                    "description": "Continue execution",
                    "inputSchema": {"type": "object", "properties": {}}
                },
                {
                    "name": "mame_step",
                    "description": "Single step execution",
                    "inputSchema": {"type": "object", "properties": {}}
                },
                {
                    "name": "mame_read_registers",
                    "description": "Read CPU registers",
                    "inputSchema": {"type": "object", "properties": {}}
                }
            ]
        }
    }

    # Read requests from stdin
    for line in sys.stdin:
        try:
            request = json.loads(line)

            if request.get('method') == 'initialize':
                print(json.dumps(server_info), flush=True)
            elif request.get('method') == 'tools/list':
                print(json.dumps(tools), flush=True)
            elif request.get('method') == 'tools/call':
                response = handle_mcp_request(request)
                result = {
                    "jsonrpc": "2.0",
                    "id": request.get('id'),
                    "result": response
                }
                print(json.dumps(result), flush=True)

        except Exception as e:
            error = {
                "jsonrpc": "2.0",
                "id": request.get('id', None),
                "error": {
                    "code": -32603,
                    "message": str(e)
                }
            }
            print(json.dumps(error), flush=True)


if __name__ == '__main__':
    main()
