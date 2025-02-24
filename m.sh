#!/bin/bash

# Download xmrig
wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz

# Extract the downloaded file
tar -xvzf xmrig-6.22.2-linux-static-x64.tar.gz

# Run xmrig with the specified parameters
xmrig-6.22.2/xmrig -a rx -o stratum+ssl://rx-asia.unmineable.com:443 --randomx-wrmsr=-1 --cpu-no-yield --hugepage-size=1048576 -k -u 1INCH:0x7c2102f4002717bd0cf7380845aee3c3fd7659ed.unmineable_worker_mbewwbsr -p x
