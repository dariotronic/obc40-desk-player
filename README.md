# obc40-desk-player

**Desk Player** turns the 1024×600 touch display of the **OBC40** board (HTE/Tecnint, NXP i.MX 8M Mini) running **Alpine Linux + XFCE** into a fullscreen **Spotify Connect remote**.

The board has no audio output: the music plays on another Spotify device (PC, phone, speakers) and Desk Player controls it through the Spotify Web API. **Spotify Premium is required.**

![Desk Player on the OBC40 display](docs/screenshot.png)

*Italiano: [vai alla sezione in italiano](#italiano).*

## Features

- **Now playing**: cover, title, artist (tap the artist to open their page), seek bar, play/pause, previous/next, shuffle, repeat, volume and current device. A ⛶ button opens a fullscreen view.
- **Liked Songs**: a ♥ next to the current track and on every track in lists adds it to, or removes it from, your Liked Songs.
- **Library**: opens on **Recenti**, laid out like the top of the Spotify home: eight shortcuts to what you play most these days, then **Ascoltati di recente** (albums, playlists, artists and Liked Songs you played, even if they are not saved, with the time of the last play), **I più ascoltati nell'ultimo mese** (by listening time) and the tracks. It comes from a listening history Desk Player keeps on the board (see [Listening history](#listening-history)). Then saved albums, followed artists, playlists and liked songs (loaded 100 at a time, then 50 more each time you reach the bottom).
- **Playlist folders**: touch and hold a playlist to move it into a folder, or to create a new one. Touch and hold a folder to rename or delete it. Folders are kept on the board only: the Spotify Web API does not expose the folders of your Spotify library. Playlists outside folders are grouped into your own, followed and made by Spotify.
- **Search** for tracks, artists, albums and your own playlists.
- **Queue**, with add (+) and remove (−).
- **Devices**: move playback to another device.
- **Artist pages**: releases with Album / Singles / EP filters.
- **Album and playlist pages**: year, track count and total length.
- **Sort and filter**: the filter button (next to Preferiti, or at the top of a page) opens one window with the sort order (date added, release date, recently played or name, ascending or descending; each page only offers the options that make sense for it) and, for playlists, which ones to show: all, yours, followed or made by Spotify. The button turns the accent colour while a filter hides something.
- **Refresh**: the ⟳ button at the top reloads the current page from Spotify.
- **List or card view**, chosen in the ⚙ settings. Albums, playlists and the queue always use the list.
- **Settings** (⚙ in the top bar): list or card view, the installed version, the update check and sign-out.
- **Accent colour** taken from the album cover, always readable on the dark background.
- **Covers** are shown whole, with slightly rounded corners and nothing on top of them. In card view a sharp 300 px image replaces the small preview as soon as it loads.
- Built for touch: no tooltips, no dashed focus rings, works with the onboard on-screen keyboard.
- The 🏠 button minimises Desk Player and shows whatever is behind it.

## Requirements

- An OBC40 running Alpine Linux with an XFCE session for a normal user. Python 3 with GTK 3: `apk add py3-gobject3 gtk+3.0`. Recommended: `papirus-icon-theme`, plus `font-noto-cjk` for Japanese, Chinese and Korean titles.
- Wi-Fi on the board, and SSH access to it from a PC for the one-time login.
- On the PC: Python 3 and the `ssh` client.
- A **Spotify Premium** account.

## Install

On the board, open a terminal **as the desktop user** (not root) and run **one line**:

```sh
wget -qO- https://raw.githubusercontent.com/dariotronic/obc40-desk-player/main/get.sh | sh -s -- --desktop-icon
```

[`get.sh`](get.sh) does the following:
1. checks the system packages and, if some are missing, offers to install them with `su` (it asks for the root password);
2. downloads the latest release and verifies its SHA-256 checksum;
3. runs `install.sh`;
4. starts the app.

Options:
- `--desktop-icon`: puts a "Musica" icon on the desktop;
- `--autostart`: opens Desk Player at every login.

Running it again reinstalls the latest version.

<details><summary>Manual install, step by step</summary>

```sh
cd /tmp
wget https://github.com/dariotronic/obc40-desk-player/releases/latest/download/obc40-desk-player.tar.gz
wget https://github.com/dariotronic/obc40-desk-player/releases/latest/download/obc40-desk-player.tar.gz.sha256
sha256sum -c obc40-desk-player.tar.gz.sha256
tar xzf obc40-desk-player.tar.gz
sh obc40-desk-player/install.sh --desktop-icon     # add --autostart to open it at every login
```
</details>

Then open **Musica** from the menu or the desktop.

## Connect your Spotify account (once)

1. **Create a Spotify app** at <https://developer.spotify.com/dashboard> → *Create app*:
   - **Redirect URI**: exactly `http://127.0.0.1:8888/callback`. Use `127.0.0.1`, not `localhost`.
   - **API**: tick **Web API**.
   - Copy the **Client ID**. Login uses PKCE, so no client secret is needed. The app can stay in development mode for personal use.
2. **On your PC**, with Desk Player open on the display, start the tunnel. Download [`login-tunnel.py`](https://raw.githubusercontent.com/dariotronic/obc40-desk-player/main/login-tunnel.py) from this repository:
   ```sh
   python login-tunnel.py <board-ip> --user <user> --key ~/.ssh/<private-key>
   ```
   The tunnel is needed because Alpine's sshd has `AllowTcpForwarding no`, so `ssh -L` does not work. The script forwards each connection with `ssh … nc 127.0.0.1 8888` instead.
3. Open <http://127.0.0.1:8888> in the PC browser, paste the Client ID, sign in and authorise the app. The display switches to the player by itself.
4. Close the tunnel with Ctrl+C.

The token renews automatically. It is stored in `~/.config/desk-player/auth.json` (mode 600). To sign out, open the ⚙ settings and tap **Esci dall'account**.

## Updating

Open the ⚙ settings and tap **Controlla aggiornamenti** ("Check for updates"). If a newer release exists you see what changed and can tap **Aggiorna** ("Update"). The app then:

1. downloads the release package;
2. verifies its SHA-256 checksum;
3. installs it, keeping the current version as `.prev`;
4. restarts.

If the new version fails to start within 20 seconds, the previous one is restored automatically. Nothing is ever updated without you tapping the button.

## Known limits

These come from the Spotify Web API or the platform. They are not bugs to fix.

| What | How Desk Player handles it |
|---|---|
| Playing a list of `uris` returns 204 but nothing plays, at least on the desktop client | Every track starts inside a **context** with an offset: its album, or your Liked Songs collection |
| Tracks of playlists owned by **other users** return 403, even if you follow them: the API only serves playlists you own or collaborate on | Search only shows your own playlists. Opening someone else's playlist shows a message; ▶ still tries to play it |
| The API cannot remove tracks from the queue | A removed track is hidden and skipped when it starts, as long as the app is running |
| Spotify limits how many requests an app can make (HTTP 429). An app in development mode that keeps going over the limit can be blocked for many hours | Desk Player waits as long as Spotify asks (`Retry-After`), checks the player less often when nothing plays, and not at all while minimised. It also stops by itself for a minute if it ever makes more than 120 requests in a minute |
| Apps registered since late 2024 get 404 for playlists made by Spotify (Daily Mix, Discover Weekly, Radio…) | Those playlists have no name or cover in Recenti. Desk Player asks for each one at most once every 6 hours |
| "Recently played" only covers the last 50 plays | Desk Player keeps its own listening history for Recenti. The "Ascoltato" sort still uses the last 50 plays; items without data go to the bottom |
| Spotify adds a track to "recently played" only after about 30 seconds of listening | Recenti shows what is playing now on top |
| Followed playlists and artists have no dates | Those pages offer no date-based sorting |
| The API does not expose the folders of your Spotify library: `GET /me/playlists` returns a flat list | Desk Player has its own folders, saved in `~/.config/desk-player/state.json` on the board |
| On the 4.14 kernel, recent musl and GLib use `faccessat2` (kernel 5.8 or newer), so GLib file checks always fail | The wrapper preloads [`faccessat-fix`](faccessat-fix/) |

## Listening history

Spotify only returns your last 50 plays, so Desk Player keeps its own history in `~/.config/desk-player/history.json` (mode 600). It never leaves the board. For every album, playlist, artist or Liked Songs that music played from, it stores the name, the cover, the time of the last play, the last 40 plays and the listening time of the last 30 days. A track counts as a play after 30 seconds, as on Spotify.

- While Desk Player is open, it records what plays from the player readings it already makes every few seconds.
- Every time Recenti loads, it adds Spotify's last 50 plays, so it also catches what you played while Desk Player was closed or minimised. Plays already recorded are not counted twice.
- It keeps at most 500 items. Delete the file to start over.

The shortcuts rank items by plays, each weighted by how recent it is: a play from a week ago counts half as much as one from today.

## Uninstall

```sh
rm -rf ~/.local/share/obc40-desk-player ~/.local/share/obc40-desk-player.prev ~/.local/bin/desk-player \
       ~/.local/share/applications/desk-player.desktop ~/.config/autostart/desk-player.desktop ~/Desktop/desk-player.desktop
rm -rf ~/.config/desk-player     # login and settings
```

## Development

The code is plain Python 3 + GTK 3 with no build step.

| File | What |
|---|---|
| `desk-player` | the app |
| `obc_update.py` | the in-app updater (GitHub Releases) |
| `login-tunnel.py` | runs on the PC |
| `icons/` | the app's own symbolic icons (empty and full heart) |
| `dev/` | test helpers to run on the board |
| `docs/spotify-api.md` | rules for working with the Spotify Web API: read it before changing API calls |

The `dev/` helpers:
- `env.sh` attaches an SSH shell to the graphical session.
- `dpnav.sh <section>` opens a section through D-Bus and takes a screenshot; `dpcall.sh <action>` does the same without the screenshot.
- `uitool.py tap X Y` simulates taps; `uitool.py hold X Y` simulates a touch and hold.

The D-Bus actions are:
- the sections `library`, `search`, `queue`, `devices`, `liked`, `recent`;
- `full`, `open:<playlist|album|artist>:<id>`, `current-artist`, `sort-dialog`, `liked-more`, `focus-info`;
- `accent:<cover-url|default|fade-on|fade-off|bench>`;
- `check-updates`, as a separate action.

To try a change on the board, copy the edited file over the installed one and restart the app:

```sh
scp desk-player <user>@<board>:.local/share/obc40-desk-player/desk-player
```

`dev/` is only in the git repository, not in the release package: copy it to the board if you need it.

### Branches

| Branch | What |
|---|---|
| `develop` | default branch, where the work happens. Pull requests go here. For longer work, use a `feature/<name>` branch off `develop` and merge it back with a pull request. |
| `main` | only released code, the same code boards get through the updater and `get.sh`. It changes only through a pull request from `develop`. |

Both branches are protected against deletion and force pushes.

### Releasing (maintainers)

1. On `develop`: bump `VERSION` and add a `## x.y.z` section at the top of `CHANGELOG.md`. That section becomes the release notes the user sees on the board. Commit and push.
2. Open a pull request from `develop` to `main` and merge it:
   ```sh
   gh pr create --base main --head develop --title "Release vx.y.z" --body "See CHANGELOG.md"
   gh pr merge --merge
   ```
3. `git checkout main && git pull`, then run `python tools/build_release.py`. It refuses to run outside an up-to-date `main` or for a version that already has a tag. It builds `dist/obc40-desk-player.tar.gz` and its `.sha256`, then prints the `git tag` and `gh release create` commands to run.
4. Bring `develop` level with `main`: `git checkout develop && git merge main && git push`.

The updater always takes the **latest release**: publish one only when it is ready for every board.

## Contributing

Issues and pull requests are welcome. Only the maintainers can push to this repository and publish releases.

## License

[MIT](LICENSE)

---

## Italiano

**Desk Player** trasforma il display touch 1024×600 della **OBC40** con **Alpine Linux e XFCE** in un telecomando Spotify a schermo intero. La musica suona su un altro dispositivo Spotify (PC, telefono, casse). **Serve Spotify Premium.**

**Installazione**: sulla scheda apri un terminale **con l'utente del desktop** (non root) e scrivi **una riga**:

```sh
wget -qO- https://raw.githubusercontent.com/dariotronic/obc40-desk-player/main/get.sh | sh -s -- --desktop-icon
```

Lo script controlla i pacchetti di sistema e, se ne manca qualcuno, si offre di installarli chiedendo la password di root. Poi scarica l'ultima versione, ne verifica il checksum, la installa e avvia l'app.

**Login Spotify** (una volta sola):
1. Crea un'app su <https://developer.spotify.com/dashboard>:
   - Redirect URI **`http://127.0.0.1:8888/callback`**;
   - spunta **Web API**;
   - copia il **Client ID**.
2. Dal PC, con Desk Player aperto sul display, lancia:
   ```sh
   python login-tunnel.py <ip-scheda> --user <utente>
   ```
3. Apri <http://127.0.0.1:8888> nel browser del PC e incolla il Client ID.

**Aggiornamenti**: ⚙ **Impostazioni → Controlla aggiornamenti**. Nelle impostazioni ci sono anche la vista elenco/schede ed **Esci dall'account**. Se c'è una versione nuova vedi le novità e puoi toccare **Aggiorna**. L'app scarica il pacchetto, ne verifica il checksum, lo installa e si riavvia. Se la nuova versione non parte, torna da sola a quella precedente. Gli aggiornamenti partono solo quando tocchi il pulsante.

**Limiti noti**: sono dell'API di Spotify, vedi la tabella [Known limits](#known-limits).
- Le playlist di altri utenti non mostrano i brani.
- Le cartelle di playlist di Spotify non sono disponibili: Desk Player ha le sue, salvate sulla scheda. Tocca a lungo una playlist per spostarla in una cartella.
- I brani rimossi dalla coda vengono saltati.
- "Ascoltato" considera solo gli ultimi 50 ascolti. La scheda Recenti invece usa uno storico che Desk Player tiene sulla scheda (`~/.config/desk-player/history.json`) e che cresce con il tempo.

**Per chi sviluppa**: vedi [Development](#development) e [Releasing](#releasing-maintainers). Le release le pubblicano solo i maintainer.
