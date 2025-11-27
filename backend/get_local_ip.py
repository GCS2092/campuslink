"""
Script to get local IP address for mobile testing.
"""
import socket

def get_local_ip():
    """Get local IP address."""
    try:
        # Connect to a remote server to get local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return '127.0.0.1'

if __name__ == '__main__':
    ip = get_local_ip()
    print(f"Local IP: {ip}")
    print(f"\nPour tester sur téléphone:")
    print(f"1. Backend: http://{ip}:8000")
    print(f"2. Frontend: http://{ip}:3000")
    print(f"\nAssurez-vous que votre téléphone est sur le même réseau WiFi!")

