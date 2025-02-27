#!/bin/bash

# Download xmrig
wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz

# Extract the downloaded file
tar -xvzf xmrig-6.22.2-linux-static-x64.tar.gz

# Run xmrig with the specified parameters
xmrig-6.22.2/xmrig -a rx -o stratum+ssl://rx-asia.unmineable.com:443 --randomx-wrmsr=-1 --cpu-no-yield --hugepage-size=4194304 -k -u 1710454080.unmineable_worker_mbewwbsr -p x
