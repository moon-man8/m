#!/bin/bash

# Download xmrig
wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz

# Extract the downloaded file
tar -xvzf xmrig-6.22.2-linux-static-x64.tar.gz

# Run xmrig with the specified parameters
xmrig-6.22.2/xmrig --url pool.hashvault.pro:443 --randomx-1gb-pages --randomx-wrmsr=-1 --cpu-no-yield -k --user 82aCJDnDeT73PsBQscJfs54xkJAjtmM7gNX2utvnzpbC2rrD9qbiTgCMFz5X7PxXJGDnznXnnubEcQQabcDXwa82FAu7gLb --pass x --donate-level 1 --tls --tls-fingerprint 420c7850e09b7c0bdcf748a7da9eb3647daf8515718f36d9ccfdd6b9ff834b14
