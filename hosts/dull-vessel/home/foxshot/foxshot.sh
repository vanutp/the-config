## Based on https://github.com/hyprwm/contrib/blob/792f6b83dc719214e0e2a0b380c34f147b28ece2/grimblast/grimblast

set -e -o pipefail

grimblastInstanceCheck="${XDG_RUNTIME_DIR:-$XDG_CACHE_DIR:-$HOME/.cache}/grimblast.lock"
if [ -e "$grimblastInstanceCheck" ]; then
  exit 2
else
  touch "$grimblastInstanceCheck"
fi

WAYFREEZE_PID=-1

freeze() {
  wayfreeze --hide-cursor &
  WAYFREEZE_PID=$!
  sleep 0.2
}

unfreeze() {
  if [ ! $WAYFREEZE_PID -eq -1 ]; then
    kill $WAYFREEZE_PID
  fi
  WAYFREEZE_PID=-1
}

cleanup() {
  unfreeze
  rm -f "$grimblastInstanceCheck"
}

trap cleanup EXIT

getTargetDirectory() {
  # shellcheck disable=SC1091
  test -f "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs" &&
    . "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs"

  echo "${XDG_SCREENSHOTS_DIR:-${XDG_PICTURES_DIR:-$HOME}}"
}

tmp_editor_directory() {
  echo "/tmp"
}

notify() {
  dunstify -t 3000 -a grimblast "$@"
}

notifyError() {
  TITLE=${2:-"Screenshot"}
  MESSAGE=${1:-"Error taking screenshot with grim"}
  notify -u critical "$TITLE" "$MESSAGE"
  echo "$1" >&2
}

die() {
  MSG=${1:-Bye}
  notifyError "Error: $MSG"
  exit 2
}

ACTION=${1:-"copy"}
FILENAME=${2:-$(tmp_editor_directory)/$(date -Ins).png}

if [ "$ACTION" != "copy" ] && [ "$ACTION" != "edit" ]; then
  echo "Unknown action" >&2
  exit
fi

freeze

# disable animation for layer namespace "selection" (slurp)
# this removes the black border seen around screenshots
hyprctl keyword layerrule "noanim,selection" >/dev/null

WORKSPACES="$(hyprctl monitors -j | jq -r '[(foreach .[] as $monitor (0; if $monitor.specialWorkspace.name == "" then $monitor.activeWorkspace else $monitor.specialWorkspace end)).id]')"
WINDOWS="$(hyprctl clients -j | jq -r --argjson workspaces "$WORKSPACES" 'map(select([.workspace.id] | inside($workspaces)))')"
WINDOWS_SIZES=$(echo "$WINDOWS" | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
MONITORS_SIZES=$(hyprctl monitors -j | jq -r '.[] | "\(.x),\(.y) \(.width/.scale)x\(.height/.scale)"')
SELECTED_GEOM=$(printf "%s\n%s" "$WINDOWS_SIZES" "$MONITORS_SIZES" | slurp -d)

# Check if user exited slurp without selecting the area
if [ -z "$SELECTED_GEOM" ]; then
  exit 1
fi

takeScreenshot() {
  grim -g "$SELECTED_GEOM" "$1" || die "Unable to invoke grim"
}

if [ "$ACTION" = "copy" ]; then
  takeScreenshot - | wl-copy --type image/png || die "Clipboard error"
elif [ "$ACTION" = "edit" ]; then
  if takeScreenshot "$FILENAME"; then
    unfreeze
    satty --copy-command wl-copy --filename "$FILENAME" || die "Failed to open satty"
    echo "$FILENAME"
  else
    notifyError "Error taking screenshot"
  fi
else
  notifyError "Unknown action"
fi
