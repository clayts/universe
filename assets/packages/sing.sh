set -euo pipefail
tput civis
fail() { printf '%s\n' "$*" >&2; exit 1; }
play() {
    echo ""
    mpv --really-quiet --scripts-add="$mpris/share/mpv/scripts/mpris.so" "$1"
}

[[ $# -ge 1 ]] || fail "usage: ${0##*/} <query…>"
cache="$HOME/.cache/sing"
query="$*"
query_dir="$cache/by-query"
id_dir="$cache/by-id"
query_path="$query_dir/$query.mp3"
if [[ -L "$query_path" ]]; then
    play "$query_path"
    exit 0
fi
echo -ne " \\r"
video_id="$(
    yt-dlp \
        -q \
        --no-playlist \
        --print id \
        --skip-download \
        "ytsearch1:$query"
)" || fail "yt-dlp failed to resolve query: $query"
[[ -n "$video_id" ]] || fail "no results found for: $query"
id_path="$id_dir/${video_id}.mp3"
if [[ ! -f "$id_path" ]]; then
    echo -ne " \\r"
    mkdir -p "$id_dir"
    yt-dlp \
        -q \
        -t mp3 \
        --no-playlist \
        --output "$id_dir/%(id)s.%(ext)s" \
        -- "https://www.youtube.com/watch?v=$video_id" \
    || fail "yt-dlp failed to download video: $video_id"
fi
mkdir -p "$query_dir"
ln -sf "../by-id/${video_id}.mp3" "$query_path"
play "$query_path"
