#                                      
# █░█░█ ▄▀█ █░░ █░░ █▀█ ▄▀█ █▀█ █▀▀ █▀█
# ▀▄▀▄▀ █▀█ █▄▄ █▄▄ █▀▀ █▀█ █▀▀ ██▄ █▀▄
#

#!/bin/bash

# Set Variables
wall_dir="${HOME}/.config/backgrounds/"
cacheDir="${HOME}/.cache/bg/"
rofi_command="rofi -dmenu -theme ${HOME}/.config/rofi/wallSelect.rasi -theme-str ${rofi_override}"

# Create Cache Directory
mkdir -p "${cacheDir}"

# Monitor Size (Inches)
physical_monitor_size=14
monitor_res=$(hyprctl monitors | grep -A2 Monitor | head -n 2 | awk '{print $1}' | grep -oE '^[0-9]+')
dotsperinch=$(echo "scale=2; $monitor_res / $physical_monitor_size" | bc | xargs printf "%.0f")
monitor_res=$(( monitor_res * physical_monitor_size / dotsperinch ))

rofi_override="element-icon{size:${monitor_res}px;border-radius:0px;}"

# Convert Images & Cache
for imagen in "$wall_dir"/*; do
    if [[ -f "$imagen" && "$imagen" =~ \.(jpg|jpeg|png|webp)$ ]]; then
        nombre_archivo=$(basename "$imagen")
        if [ ! -f "${cacheDir}/${nombre_archivo}" ]; then
            magick convert -strip "$imagen" -thumbnail 500x500^ -gravity center -extent 500x500 "${cacheDir}/${nombre_archivo}"
        fi
    fi
done

# Rofi Picture Select
wall_selection=$(find "${wall_dir}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | \
while read -r A; do
    echo -en "$A\x00icon\x1f${cacheDir}/$A\n"
done | $rofi_command)

# Set Wallpaper & Notify
if [[ -n "$wall_selection" ]]; then
    swww img "${wall_dir}/${wall_selection}"
    notify-send "Swww" "Wallpaper Updated"
else
    exit 1
fi

exit 0