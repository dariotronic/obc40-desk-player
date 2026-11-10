#!/bin/sh
# One-line installer for obc40-desk-player. Run it as the desktop user (not root), e.g. in a terminal on the
# display:
#
#   wget -qO- https://raw.githubusercontent.com/dariotronic/obc40-desk-player/main/get.sh | sh
#
# Options (after `sh -s --`):  --desktop-icon   put a "Musica" icon on the desktop
#                              --autostart      start Desk Player at every login
#
# It downloads the latest release from GitHub, verifies its SHA-256 checksum, runs its install.sh and
# starts Desk Player. Missing system packages are installed with `su` after asking.
set -e
REPO=dariotronic/obc40-desk-player
NAME=obc40-desk-player
OPTS=""
for a in "$@"; do
  case "$a" in
    --desktop-icon|--autostart) OPTS="$OPTS $a" ;;
    *) echo "unknown option: $a" >&2; exit 1 ;;
  esac
done

if [ "$(id -u)" = 0 ]; then
  echo "Run this as the desktop user, not as root: Desk Player is installed in your home directory." >&2
  exit 1
fi

# --- system packages
need=""
python3 -c 'import gi; gi.require_version("Gtk", "3.0"); gi.require_version("GdkPixbuf", "2.0"); from gi.repository import Gtk, GdkPixbuf' 2>/dev/null \
  || need="$need py3-gobject3 gtk+3.0"
if [ -n "$need" ]; then
  echo "Missing system packages:$need"
  if (: </dev/tty) 2>/dev/null; then     # an interactive terminal is available
    printf "Install them now with su (asks for the root password)? [Y/n] "
    read -r ans </dev/tty || ans=n
    case "$ans" in n|N|no) echo "Install them with: su -c 'apk add$need'" >&2; exit 1 ;; esac
    su -c "apk add$need" </dev/tty
  else
    echo "Install them with: su -c 'apk add$need'  and run this again." >&2
    exit 1
  fi
fi

# --- download, verify, install
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
base="https://github.com/$REPO/releases/latest/download"
echo "== $NAME: downloading the latest release"
wget -q -O "$TMP/$NAME.tar.gz" "$base/$NAME.tar.gz"
wget -q -O "$TMP/$NAME.tar.gz.sha256" "$base/$NAME.tar.gz.sha256"
expected=$(cut -d' ' -f1 "$TMP/$NAME.tar.gz.sha256" | tr -d '\r')
actual=$(sha256sum "$TMP/$NAME.tar.gz" | cut -d' ' -f1)
[ "$expected" = "$actual" ] || { echo "$NAME: checksum mismatch, nothing installed" >&2; exit 1; }
tar xzf "$TMP/$NAME.tar.gz" -C "$TMP"
sh "$TMP/$NAME/install.sh" $OPTS

# --- start it now, if a graphical session is running (restart it if it was already open)
if [ -z "$DISPLAY" ]; then
  P=$(pgrep -u "$(id -un)" -x xfce4-session | head -1 || true)
  if [ -n "$P" ]; then
    eval "export $(tr '\0' '\n' < /proc/$P/environ | grep -E '^(DISPLAY|XAUTHORITY|DBUS_SESSION_BUS_ADDRESS)=' \
      | sed 's/=\(.*\)/="\1"/' | tr '\n' ' ')"
  fi
fi
if [ -n "$DISPLAY" ]; then
  pkill -f "^python3 .*/obc40-desk-player/desk-player\$" 2>/dev/null || true
  sleep 1
  (setsid "$HOME/.local/bin/desk-player" >/dev/null 2>&1 </dev/null &)
  echo "== done: Desk Player is starting on the display"
else
  echo "== done: no graphical session found, open \"Musica\" from the menu at the next login"
fi
echo "To connect Spotify: https://github.com/$REPO#connect-your-spotify-account-once"
