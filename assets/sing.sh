if [[ $# -eq 0 ]]; then
    echo "Usage: $0 search terms"
fi
query="$*"
if [[ ! -f "$HOME/.local/share/sing/$query.mp3" ]]; then
    mkdir -p "$HOME/.local/share/sing"
    yt-dlp -q -t mp3 "ytsearch:$query" -o "$HOME/.local/share/sing/$query.mp3"
fi
mpv --really-quiet --scripts-add="$mpris/share/mpv/scripts/mpris.so" "$HOME/.local/share/sing/$query.mp3"
