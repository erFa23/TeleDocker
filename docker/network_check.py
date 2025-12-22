import socket
import threading
import time
import urllib.request
import sys

def start_temp_server(port, message):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            s.bind(('127.0.0.1', port))
            s.listen(1)
            conn, addr = s.accept()
            with conn:
                conn.recv(1024)
                conn.sendall(f'HTTP/1.1 200 OK\n\n{message}'.encode())
    except:
        pass

def check_port_integrity(port, message):
    print(f"  - Starting network integrity test on port {port}...")
    
    t = threading.Thread(target=start_temp_server, args=(port, message), daemon=True)
    t.start()
    time.sleep(1)

    try:
        proxy_handler = urllib.request.ProxyHandler({})
        opener = urllib.request.build_opener(proxy_handler)
        with opener.open(f'http://127.0.0.1:{port}', timeout=3) as f:
            response = f.read().decode()
            if message in response:
                print(f"    Success: Port {port} and local network path are clear.")
                return True
    except Exception as e:
        print(f"\nError: Connection to port {port} failed!")
        print(f"   Reason: \n{e}")
        return False
    return False

if __name__ == "__main__":
    target_port = int(sys.argv[1])
    test_msg = sys.argv[2]
    
    if not check_port_integrity(target_port, test_msg):
        sys.exit(1)
    
    print("\n** All Python-based network checks passed. **")
    sys.exit(0)