useradd --system spm
mkdir -p /state/spm
chown spm /state/spm

cp /mnt/os/spm.sh /bin/spm
chmod +x /bin/spm

# /bin/spm autoupdate
# if AC Power
# after network online
# oneshot service
# TimeoutStopSec=900
# 5min after boot
# every 24h
# 5min randomized delay
