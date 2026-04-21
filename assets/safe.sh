set -euo pipefail

case "$1" in
    unlock)
        if [ -d ~/Safe ]; then
            echo \~/Safe already unlocked
            exit 1
        else
            echo -n "Password: "
            mkdir -p ~/.local/share/safe/{locked,unlocked}
            (CRYFS_FRONTEND=noninteractive cryfs \
                ~/.local/share/safe/{locked,unlocked} > /dev/null &&
            echo "✔" || exit 1)
            ln -s ~/.local/share/safe/unlocked ~/Safe
            echo \~/Safe unlocked
        fi
        ;;
    lock)
        if [ -d ~/Safe ]; then
            CRYFS_FRONTEND=noninteractive cryfs-unmount \
                --immediate \
                ~/.local/share/safe/unlocked > /dev/null #2>&1
            rm ~/Safe
            echo \~/Safe locked
        else
            echo \~/Safe already locked
            exit 1
        fi
        ;;
    status)
        if [ -d ~/Safe ]; then
            echo \~/Safe is unlocked
        else
            echo \~/Safe is locked
        fi
        ;;
    *)
        echo "usage: $0 [status|lock|unlock]"
        exit 1
        ;;
esac
