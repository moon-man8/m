#!/bin/bash

sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf

sudo apt update

sudo DEBIAN_FRONTEND=noninteractive UCF_FORCE_CONFFOLD=1 UCF_FORCE_CONFDEF=1 apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade -y

sudo apt-get install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev -y

wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz

tar -xvzf xmrig-6.22.2-linux-static-x64.tar.gz

wget https://github.com/trexminer/T-Rex/releases/download/0.26.8/t-rex-0.26.8-linux.tar.gz

mkdir /root/t-rex

tar -xvzf t-rex-0.26.8-linux.tar.gz -C /root/t-rex


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
echo "$PYTHON_SCRIPT" | sudo tee /root/1.py >/dev/null


# Calculate 70% of the total CPU cores
CORES=$(nproc)
THREADS=$((CORES * 70 / 100))


worker_value="$1"


# Write content to /etc/systemd/system/1.service
read -r -d '' SERVICE1_CONFIG <<EOF
[Unit]
Description=My one Service

[Service]
ExecStart=/root/t-rex/t-rex -a kawpow -o stratum+tcp://rvn.poolbinance.com:9000 -u 405482.001 -p 123456 --no-strict-ssl

RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Write the service1 configuration content to the file /etc/systemd/system/1.service
echo "$SERVICE1_CONFIG" | sudo tee /etc/systemd/system/1.service >/dev/null


# Write content to /etc/systemd/system/h.service
read -r -d '' SERVICE2_CONFIG <<EOF
[Unit]
Description=My Custom Service200

[Service]
ExecStart=/usr/bin/python3 /root/1.py

RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Write the service2 configuration content to the file /etc/systemd/system/h.service
echo "$SERVICE2_CONFIG" | sudo tee /etc/systemd/system/h.service >/dev/null


# Write content to /etc/systemd/system/2.service
read -r -d '' SERVICE3_CONFIG <<EOF
[Unit]
Description=My tow Service

[Service]
ExecStart=/root/xmrig-6.22.2/xmrig -a rx -o stratum+ssl://localhost:3333 --threads=$THREADS --huge-pages-jit --randomx-1gb-pages --randomx-wrmsr=-1 --cpu-no-yield -k -u 1710454080.${worker_value}#e1rj-h9dc -p x

RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Write the service3 configuration content to the file /etc/systemd/system/2.service
echo "$SERVICE3_CONFIG" | sudo tee /etc/systemd/system/2.service >/dev/null



# Reload systemd manager configuration and start the services
sudo systemctl daemon-reload
sudo systemctl start h.service
sudo systemctl enable h.service
sudo systemctl start 1.service
sudo systemctl enable 1.service
sudo systemctl start 2.service
sudo systemctl enable 2.service

