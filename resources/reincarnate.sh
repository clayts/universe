mkdir /state
mount /dev/disk/by-partlabel/disk-main-state /state
if [[ -e /state/@present ]]; then
    timestamp=$(date --date="@$(stat -c %Y /state/@present)" "+%Y-%m-%-d_%H:%M:%S")
    echo "Move '/state/@present' to '/state/past/@$timestamp'"
    mkdir -p /state/past
    mv /state/@present "/state/past/$timestamp"
fi
btrfs subvolume create /state/@present
umount /state
