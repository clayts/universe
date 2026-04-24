if [[ $# -eq 0 ]]; then
    echo "Usage: $0 search terms"
fi
query="$*"
if [[ ! -f "$HOME/.cache/sing/$query.mp3" ]]; then
    mkdir -p "$HOME/.cache/sing"
    yt-dlp -q -t mp3 "ytsearch:$query" -o "$HOME/.cache/sing/$query.mp3"
fi
echo "♫"
mpv --really-quiet --scripts-add="$mpris/share/mpv/scripts/mpris.so" "$HOME/.cache/sing/$query.mp3"
