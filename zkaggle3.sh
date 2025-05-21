#!/bin/bash

wget https://github.com/trexminer/T-Rex/releases/download/0.26.8/t-rex-0.26.8-linux.tar.gz

mkdir /kaggle/working/t-rex

tar -xvzf t-rex-0.26.8-linux.tar.gz -C /kaggle/working/t-rex

# Write content to /root/1.py
read -r -d '' PYTHON_SCRIPT <<'EOF'
import socket
import threading
import json

# Proxy Settings
PROXY_HOST = '0.0.0.0'
PROXY_PORT = 3333  # The port XMRig connects to
POOL_HOST = 'rvn.poolbinance.com'  # Test pool address
POOL_PORT = 9000   # Pool port

# Hashrate Multiplier (e.g., 2x)
HASHRATE_MULTIPLIER = 100

def handle_client(client_socket):
    # Connect to the actual pool
    pool_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    pool_socket.connect((POOL_HOST, POOL_PORT))

    # Forward messages from XMRig to the pool
    def forward_to_pool():
        while True:
            data = client_socket.recv(4096)
            if not data:
                break
            # Send original data to the pool
            pool_socket.send(data)

    # Forward messages from the pool to XMRig with modifications
    def forward_to_client():
        while True:
            data = pool_socket.recv(4096)
            if not data:
                break
            try:
                # Parse Stratum message (JSON)
                message = json.loads(data.decode())

                # If the message contains "result" (e.g., hashrate report)
                if 'result' in message and 'hashes' in message['result']:
                    message['result']['hashes'] *= HASHRATE_MULTIPLIER
                    print(f"Hashrate modified to: {message['result']['hashes']}")

                # Send the modified message to XMRig
                client_socket.send(json.dumps(message).encode())
            except:
                # Send data unmodified in case of error
                client_socket.send(data)

    # Run the threads
    threading.Thread(target=forward_to_pool).start()
    threading.Thread(target=forward_to_client).start()

# Run the proxy
def main():
    proxy = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    proxy.bind((PROXY_HOST, PROXY_PORT))
    proxy.listen(5)
    print(f"Proxy is running on {PROXY_HOST}:{PROXY_PORT}")

    while True:
        client_socket, addr = proxy.accept()
        print(f"New connection from {addr[0]}:{addr[1]}")
        threading.Thread(target=handle_client, args=(client_socket,)).start()

if __name__ == '__main__':
    main()
EOF

# Write the Python script content to the file /root/1.py
echo "$PYTHON_SCRIPT" | sudo tee /kaggle/working/1.py >/dev/null
