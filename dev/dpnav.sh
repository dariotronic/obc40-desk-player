#!/bin/sh
# Opens a Desk Player section via D-Bus and takes a screenshot (/tmp/shot.png). Run on the board:
#   sh dev/dpnav.sh <library|search|queue|devices|liked|recent|full|open:album:<id>|...> [seconds]
D=$(dirname "$0")
. "$D/env.sh"
gdbus call --session --dest it.dario.deskplayer --object-path /it/dario/deskplayer \
  --method org.gtk.Actions.Activate navigate "[<'$1'>]" "{}" >/dev/null
sleep "${2:-4}"
sh "$D/shot.sh"
