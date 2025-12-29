#!/usr/bin/env python3
"""
Set breakpoints in MAME via GDB stub.
Used for debugging SCASM loader and initialization.
"""

import socket
import sys


def send_gdb_command(cmd):
    """Send GDB remote protocol command to MAME"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2.0)
        sock.connect(('localhost', 2159))

        # Calculate checksum
        checksum = sum(ord(c) for c in cmd) & 0xFF
        packet = f"${cmd}#{checksum:02x}"
        sock.sendall(packet.encode())

        # Read response
        response = sock.recv(1024)
        sock.close()

        return response.decode() if response else None
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return None


def set_breakpoint(address):
    """Set software breakpoint at address"""
    # Z0 = software breakpoint, address in hex, size=1
    cmd = f"Z0,{address:x},1"
    response = send_gdb_command(cmd)

    if response and '+' in response:
        print(f"✓ Breakpoint set at ${address:04X}")
        return True
    else:
        print(f"✗ Failed to set breakpoint at ${address:04X}: {response}")
        return False


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: mcp-set-breakpoints.py [--loader | address1 address2 ...]")
        sys.exit(1)

    if sys.argv[1] == '--loader':
        # Common loader breakpoints
        breakpoints = [
            0x2000,  # Loader entry point
            0x211E,  # MOVE routine entry
            0x201C,  # Second MOVE call
        ]
    else:
        # Parse addresses from command line
        breakpoints = [int(addr, 0) for addr in sys.argv[1:]]

    success_count = 0
    for addr in breakpoints:
        if set_breakpoint(addr):
            success_count += 1

    if success_count == len(breakpoints):
        sys.exit(0)
    else:
        print(f"\nSet {success_count}/{len(breakpoints)} breakpoints")
        sys.exit(1)


if __name__ == '__main__':
    main()
