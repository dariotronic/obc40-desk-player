#!/bin/sh
# Like dpnav.sh, without the screenshot. Run on the board:  sh dev/dpcall.sh <action>
. "$(dirname "$0")/env.sh"
gdbus call --session --dest it.dario.deskplayer --object-path /it/dario/deskplayer \
  --method org.gtk.Actions.Activate navigate "[<'$1'>]" "{}" >/dev/null
