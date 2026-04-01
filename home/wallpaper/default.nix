{pkgs, ...}: let
  earthpaper = pkgs.writeShellScriptBin "earthpaper" ''

    target_dir="$HOME/.earthpaper"

    tmp_dir=$(mktemp -d)

    id=$(${pkgs.jq}/bin/jq -r '.[]' ${./image-ids.json} | shuf -n 1)

    ${pkgs.curl}/bin/curl -s "https://www.gstatic.com/prettyearth/assets/data/v3/$id.json" -o $tmp_dir/data.json

    if [ ! -f "$tmp_dir/data.json" ]; then
    	echo "Could not fetch data"
    	exit 1
    fi

    read -r latitude longitude elevation country attribution < <(${pkgs.jq}/bin/jq -r '.lat, .lng, .elevation, .geocode.country, .attribution' $tmp_dir/data.json | tr '\n' ' ')
    url="https://maps.google.com/?q=$latitude,$longitude"

    mkdir -p $target_dir

    ${pkgs.jq}/bin/jq -r '.dataUri' $tmp_dir/data.json | sed 's/^data:image\/jpeg;base64,//' | base64 -d > "$target_dir/image.jpeg"

    echo """ID:          $id
    Country:     $country
    Latitude:    $latitude
    Longitude:   $longitude
    Elevation:   $elevation
    Map URL:     $url
    Attribution: $attribution""" > "$target_dir/info.txt"

    cat "$target_dir/info.txt"

    rm -Rf $tmp_dir

    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/background/picture-uri "'none'" &&
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/background/picture-uri "'$target_dir/image.jpeg'"
  '';
in {
  systemd.user.services."earthpaper" = {
    Unit = {
      Description = "Earthpaper switcher";
      StartLimitBurst = 10; # Maximum retries
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${earthpaper}/bin/earthpaper";
      Restart = "on-failure";
      RestartSec = 900; # seconds between retries
    };
  };

  systemd.user.timers."earthpaper" = {
    Unit.Description = "Timer for earthpaper service";
    Timer = {
      Unit = "earthpaper.service";
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = ["timers.target"];
  };
}
