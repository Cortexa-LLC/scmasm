#!/usr/bin/env python3
"""
Simple helper to send continue command to MAME GDB stub.
Used to unpause MAME when it starts in debug mode.
"""

import socket
import sys


def send_continue():
    """Send continue command to MAME GDB stub"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2.0)
        sock.connect(('localhost', 2159))

        # Send continue command
        cmd = "c"
        checksum = sum(ord(c) for c in cmd) & 0xFF
        packet = f"${cmd}#{checksum:02x}"
        sock.sendall(packet.encode())

        # Wait for ack
        response = sock.recv(256)

        sock.close()
        return True
    except Exception as e:
        print(f"Failed to send continue: {e}", file=sys.stderr)
        return False


if __name__ == '__main__':
    if send_continue():
        print("✓ Sent continue command to MAME")
        sys.exit(0)
    else:
        print("✗ Failed to send continue command", file=sys.stderr)
        sys.exit(1)
