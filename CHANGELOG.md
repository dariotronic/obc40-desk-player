# Changelog

All notable changes to obc40-desk-player. Versions follow [semantic versioning](https://semver.org/).

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
