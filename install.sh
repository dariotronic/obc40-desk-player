#!/bin/sh
# obc40-desk-player installer: installs Desk Player for the current user (no root needed).
#
#   sh install.sh                  first install: app and "Musica" menu entry
#   sh install.sh --autostart      also start Desk Player at every login
#   sh install.sh --desktop-icon   also put a "Musica" icon on the desktop
#   sh install.sh --update         used by the in-app updater: replaces the app files only
#
# Files: ~/.local/share/obc40-desk-player/ (app), ~/.local/share/obc40-desk-player.prev/ (previous
#        version), ~/.local/bin/desk-player (wrapper), ~/.config/desk-player/ (login and settings).
set -e
NAME=obc40-desk-player
SRC=$(cd "$(dirname "$0")" && pwd)
DEST="$HOME/.local/share/$NAME"
BIN="$HOME/.local/bin"
UPDATE=0
AUTOSTART=0
ICON=0
for a in "$@"; do
  case "$a" in
    --update) UPDATE=1 ;;
    --autostart) AUTOSTART=1 ;;
    --desktop-icon) ICON=1 ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "unknown option: $a" >&2; exit 1 ;;
  esac
done
[ "$SRC" != "$DEST" ] || { echo "run install.sh from the downloaded package, not from $DEST" >&2; exit 1; }

# --- requirements
python3 -c 'import gi; gi.require_version("Gtk", "3.0"); gi.require_version("GdkPixbuf", "2.0"); from gi.repository import Gtk, GdkPixbuf' 2>/dev/null || {
  echo "Missing Python GTK3. Install it as root and run again:  apk add py3-gobject3 gtk+3.0" >&2; exit 1; }

# --- app files: new copy, then swap (the previous version stays in $DEST.prev)
rm -rf "$DEST.new"
mkdir -p "$DEST.new"
cp -R "$SRC/." "$DEST.new/"
rm -rf "$DEST.new/.git" "$DEST.new/__pycache__"
chmod 755 "$DEST.new/desk-player"
if [ -d "$DEST" ]; then
  rm -rf "$DEST.prev"
  mv "$DEST" "$DEST.prev"
fi
mv "$DEST.new" "$DEST"
if [ "$UPDATE" = 1 ]; then
  touch "$DEST.updated"   # removed by the app once it has run fine for 20 s
else
  rm -f "$DEST.updated"
fi

# --- wrapper: faccessat-fix on kernels < 5.8, rollback if an update crashes at start
mkdir -p "$BIN"
cat > "$BIN/desk-player" <<'EOF'
#!/bin/sh
# obc40-desk-player wrapper (written by install.sh)
D="$HOME/.local/share/obc40-desk-player"
K=$(uname -r); KMAJ=${K%%.*}; KMIN=${K#*.}; KMIN=${KMIN%%.*}
if [ "$KMAJ" -lt 5 ] || { [ "$KMAJ" -eq 5 ] && [ "$KMIN" -lt 8 ]; }; then
  export LD_PRELOAD="$D/faccessat-fix/faccessat-fix.so${LD_PRELOAD:+:$LD_PRELOAD}"
fi
start=$(date +%s)
python3 "$D/desk-player" "$@"
rc=$?
if [ "$rc" -ne 0 ] && [ -f "$D.updated" ] && [ -d "$D.prev" ] && [ $(( $(date +%s) - start )) -lt 20 ]; then
  echo "obc40-desk-player: the update did not start, going back to the previous version" >&2
  cat "$D/VERSION" > "$D.rolledback" 2>/dev/null
  rm -rf "$D.failed"; mv "$D" "$D.failed" && mv "$D.prev" "$D"; rm -f "$D.updated"
  exec "$0" "$@"
fi
exit $rc
EOF
chmod 755 "$BIN/desk-player"

if [ "$UPDATE" = 0 ]; then
  mkdir -p "$HOME/.local/share/applications"
  cat > "$HOME/.local/share/applications/desk-player.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Musica
GenericName=Desk Player
Comment=Telecomando Spotify a schermo intero
Exec=$BIN/desk-player
Icon=spotify
Terminal=false
Categories=AudioVideo;Audio;Player;
EOF
  if [ "$AUTOSTART" = 1 ]; then
    mkdir -p "$HOME/.config/autostart"
    cp "$HOME/.local/share/applications/desk-player.desktop" "$HOME/.config/autostart/"
  fi
  if [ "$ICON" = 1 ]; then
    DESKDIR=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
    mkdir -p "$DESKDIR"
    cp "$HOME/.local/share/applications/desk-player.desktop" "$DESKDIR/"
    chmod +x "$DESKDIR/desk-player.desktop"
  fi
fi

echo "obc40-desk-player $(cat "$DEST/VERSION") installed in $DEST"
if [ "$UPDATE" = 0 ]; then
  echo "Start it with: $BIN/desk-player  (or \"Musica\" in the menu)"
  echo "First login from a PC: python login-tunnel.py <board-ip> --user $(id -un), then open http://127.0.0.1:8888"
fi
