mkdir /state
mount /dev/disk/by-partlabel/disk-main-state /state
if [[ -e /state/@present ]]; then
    timestamp=$(date --date="@$(stat -c %Y /state/@present)" "+%Y-%m-%-d_%H:%M:%S")
    mv /state/@present "/state/@$timestamp"
fi
btrfs subvolume create /state/@present
umount /state
