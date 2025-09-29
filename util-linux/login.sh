#!/usr/bin/env sh

rm -rf /run/user/1000
mkdir -p /run/user/1000
chown 1000:1000 /run/user/1000
chmod 700 /run/user/1000

# 1,2 are input,video groups
setpriv --reuid=1000 --regid=1000 --groups=1,2 --inh-caps=-all /usr/bin/shell
