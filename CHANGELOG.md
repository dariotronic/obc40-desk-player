# Changelog

All notable changes to obc40-desk-player. Versions follow [semantic versioning](https://semver.org/).

## 0.1.1

- Fixed: 0.1.0 could make far too many requests to Spotify, and Spotify could then block the app for many hours.
  - Cause: while a playlist made by Spotify was playing (Daily Mix, Discover Weekly, Radio…), Desk Player asked for its name every 2 seconds. Apps registered since late 2024 always get an error for those playlists.
  - Now a playlist, album or artist that Spotify does not return is asked for at most once every 6 hours, and at most 10 new ones are looked up per minute.
  - When the ♥ state of a track cannot be read, Desk Player waits 5 minutes before trying again.
  - Safety limit: if Desk Player ever makes more than 120 requests in a minute, it stops for the rest of that minute and says so.

## 0.1.0

- **Recenti** is laid out like the top of the Spotify home: eight shortcuts to what you play most these days, then **Ascoltati di recente**, **I più ascoltati nell'ultimo mese** and the tracks. It now includes artists and Liked Songs, and is no longer limited to the last 50 plays.
- Listening history: Desk Player keeps its own history on the board, in `~/.config/desk-player/history.json`. It records what played and for how long, from the player and from Spotify's last 50 plays, and never leaves the board.
- **Playlist folders**:
  - touch and hold a playlist to move it into a folder or to create a new one;
  - touch and hold a folder to rename or delete it; deleting a folder leaves its playlists in the library;
  - the folders are kept on the board, because the Spotify Web API does not expose the folders of your Spotify library.
- The Playlist tab shows the folders first, then the other playlists grouped into **Le tue playlist**, **Seguite** and **Di Spotify**.
- **Sort and filter**: sorting is now in one window, opened by the filter button (three lines) next to Preferiti and at the top of playlist, Liked Songs and artist pages.
  - For playlists, the same window also shows **Tutte**, **Mie**, **Seguite** or **Di Spotify**, and explains how folders work.
  - The button turns the accent colour while a filter is active.
- **Settings**: the new ⚙ button in the top bar replaces the list/card switch. It holds:
  - the list or card view;
  - the installed version;
  - **Controlla aggiornamenti** and **Esci dall'account**, which both moved there from Dispositivi.
- **Refresh**: one ⟳ button in the top bar reloads any page. The separate refresh buttons in Recenti, Coda and Dispositivi are gone.
- The 🏠 icon in the top bar is now the same size as ⟳ and ⚙.
- Fixed: the on-screen keyboard sometimes did not appear when tapping the search bar or a text field. Desk Player now opens and closes onboard itself, instead of relying only on onboard's auto-show, which can stop working until onboard is restarted.

## 0.0.5

- Fixed: the ♥ next to the current track now shows; in 0.0.4 it stayed hidden.
- Sharper covers in card view: the small preview appears at once and is replaced by a 300 px image as soon as it loads.
- Recenti shows on top the album or playlist that is playing and its track: Spotify adds a track to its history only after about 30 seconds.
- Covers are shown whole, never cropped, with slightly rounded corners; in card view the buttons sit below the cover instead of on top of it.
- Playback buttons that Spotify does not allow at the moment are disabled.
- Tap the title in the side panel to read it in full in the fullscreen view.
- The ♥ messages now say "Aggiunto a Brani che ti piacciono" and "Rimosso da Brani che ti piacciono".

## 0.0.4

- Liked Songs: tap the ♥ next to the current track, or on any track in a list, to add it to your Liked Songs or remove it. It uses Spotify's current library endpoint.
- If Spotify has not granted all the permissions this version needs, Desk Player says so once and shows how to sign in again (Dispositivi → Esci dall'account).

## 0.0.3

- The library opens on the new **Recenti** tab: the albums and playlists you played recently, even if they are not in your library, with the time of the last play, then the tracks. The tabs are now Recenti, Album, Artisti, Playlist, Preferiti.
- Saved albums can no longer be sorted by "Ascoltato": it only looked at the last 50 plays and rarely matched a saved album. Use the Recenti tab instead.
- Follows Spotify's rate limits: when Spotify asks to slow down, Desk Player waits the time it asks for and shows one message, instead of retrying every few seconds.
- Fewer requests to Spotify: the player is checked every 2 s while playing, 5 s when paused, 15 s after 10 minutes without music, and not at all while Desk Player is minimised.
- Playlists read the current `item` field (Spotify has deprecated `track`) and stay within the documented page size. Artist pages open with one request fewer.
- Lists are kept in memory for at most 30 minutes, then reloaded from Spotify.
- The login page on 127.0.0.1:8888 is only active while no account is connected. The settings folder is now private (mode 700).

## 0.0.2

- The 🏠 button now simply minimises Desk Player, showing whatever is behind it.
- One-line installer: `wget -qO- https://raw.githubusercontent.com/dariotronic/obc40-desk-player/main/get.sh | sh`.
- Release checksums use LF line endings, so `sha256sum -c` works.

## 0.0.1

First public release.

- Fullscreen Spotify Connect remote for the OBC40 1024×600 display (Spotify Premium needed): now playing with cover, seek bar, play/pause, previous/next, shuffle, repeat, volume and device; tap the artist to open their page; fullscreen now-playing view.
- Library (playlists, albums, artists, liked songs loaded 100 + 50 at a time, recently played), search, queue with add/remove, device switching.
- Artist page with Albums / Singles / EPs filters; year, track count and total length for albums and playlists.
- Sorting by date added, release date, recently played or name, ascending or descending, with only the options that make sense on each page.
- List or card view; the accent colour follows the album cover.
- One-time login from a PC through `login-tunnel.py` (PKCE, no client secret stored).
- Manual updates: Devices → "Controlla aggiornamenti"; the previous version is kept and restored automatically if the new one does not start.
