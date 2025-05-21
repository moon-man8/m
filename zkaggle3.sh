#!/bin/bash

wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz

tar -xvzf xmrig-6.22.2-linux-static-x64.tar.gz

# Write content to /root/1.py
read -r -d '' PYTHON_SCRIPT <<'EOF'
import socket
import threading
import json

# إعدادات البروكسي
PROXY_HOST = '0.0.0.0'
PROXY_PORT = 3333  # المنفذ الذي يتصل به XMRig
POOL_HOST = 'rx.unmineable.com'  # عنوان البوول الاختباري
POOL_PORT = 443   # منفذ البوول

# نسبة التضخيم (مثال: 2x)
HASHRATE_MULTIPLIER = 100

def handle_client(client_socket):
    # الاتصال بالبوول الحقيقي
    pool_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    pool_socket.connect((POOL_HOST, POOL_PORT))

    # توجيه الرسائل من XMRig إلى البوول
    def forward_to_pool():
        while True:
            data = client_socket.recv(4096)
            if not data:
                break
            # إرسال البيانات الأصلية إلى البوول
            pool_socket.send(data)

    # توجيه الرسائل من البوول إلى XMRig مع التعديل
    def forward_to_client():
        while True:
            data = pool_socket.recv(4096)
            if not data:
                break
            try:
                # تحليل رسالة Stratum (JSON)
                message = json.loads(data.decode())

                # إذا كانت الرسالة تحتوي على "result" (مثال: تقرير الهاشرات)
                if 'result' in message and 'hashes' in message['result']:
                    message['result']['hashes'] *= HASHRATE_MULTIPLIER
                    print(f"تم تعديل الهاشرات إلى: {message['result']['hashes']}")

                # إرسال الرسالة المعدلة إلى XMRig
                client_socket.send(json.dumps(message).encode())
            except:
                # إرسال البيانات دون تعديل في حالة الخطأ
                client_socket.send(data)

    # تشغيل الثريدات
    threading.Thread(target=forward_to_pool).start()
    threading.Thread(target=forward_to_client).start()

# تشغيل البروكسي
def main():
    proxy = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    proxy.bind((PROXY_HOST, PROXY_PORT))
    proxy.listen(5)
    print(f"البروكسي يعمل على {PROXY_HOST}:{PROXY_PORT}")

    while True:
        client_socket, addr = proxy.accept()
        print(f"اتصال جديد من {addr[0]}:{addr[1]}")
        threading.Thread(target=handle_client, args=(client_socket,)).start()

if __name__ == '__main__':
    main()
EOF

# Write the Python script content to the file /root/1.py
echo "$PYTHON_SCRIPT" | sudo tee /kaggle/working/1.py >/dev/null

# Calculate 70% of the total CPU cores
CORES=$(nproc)
THREADS=$((CORES * 80 / 100))

