# Spotify Web API: rules for this project

Rules for anyone changing how Desk Player talks to Spotify, people and coding assistants alike. They adapt Spotify's own guidance for Web API apps to this project.

## Endpoints

- The source of truth is the [Spotify OpenAPI schema](https://developer.spotify.com/reference/web-api/open-api-schema.yaml). Check every path, parameter, limit and field name there. Do not guess.
- Do not use endpoints or fields marked `deprecated`. In particular:
  - playlist contents: `GET /playlists/{id}/items`, not `/playlists/{id}/tracks`; read each entry's `item`, not `track`;
  - saving and removing items (tracks, albums, playlists, artists): `PUT` / `DELETE /me/library?uris=…`, and `GET /me/library/contains` to check. The type-specific `PUT`/`DELETE` on `me/tracks`, `me/albums` and `me/following` are deprecated;
  - reading the library still uses `GET me/tracks`, `me/albums`, `me/playlists` and `me/following`: `/me/library` has no listing endpoint.
- Respect the `limit` maximum of each endpoint. Some are lower than you might expect: `search` and `artists/{id}/albums` allow 10, most lists allow 50. A value over the maximum returns 400.
- Follow the `next` links for pagination and keep a cap on the number of pages.

## Authorization

- Authorization Code with PKCE only. No client secret anywhere. Never the Implicit Grant.
- Redirect URI: `http://127.0.0.1:8888/callback`. Never `localhost`, never wildcards.
- Scopes: only those a feature actually uses (`SCOPES` in `desk-player`). Every scope must have a caller. A token keeps the scopes it was issued with, so adding one means the user has to sign in again.
- Tokens live in `~/.config/desk-player/auth.json` (mode 600, folder 700). Save the new refresh token whenever Spotify returns one. If the refresh token is rejected (`invalid_grant`), sign out and show the login screen.

## Rate limits

- On HTTP 429, wait for the number of seconds in `Retry-After`. If the header is missing, back off exponentially with jitter (1, 2, 4 … up to 60 s). `Spotify.call` does this; while it waits, every call fails at once with no network request.
- Never retry in a tight loop. Polling must stay adaptive: 2 s while playing, 5 s when paused, 15 s after 10 minutes idle, and none while the window is minimised or the app is rate limited.
- Do not fetch the same data twice for one screen: share results (see `recent_items`).

## Errors

- 401: refresh the token once and retry. If it fails again, the user has to sign in again.
- 403, 404, 400: show Spotify's `error.message`, or a clearer Italian text for known cases (`NO_ACTIVE_DEVICE`, `PREMIUM_REQUIRED`, playlists of other users).
- 429: one message per wait, not one per tap.

## Spotify Developer Terms

- Read the [Developer Terms](https://developer.spotify.com/terms) before adding features.
- Keep Spotify content only as long as needed for immediate use: in memory, with an expiry (lists 30 minutes). Write nothing from Spotify to disk except the login and the user's preferences, such as the last device and the view settings.
- Attribute content to Spotify following the [Design Guidelines](https://developer.spotify.com/documentation/design).
- Never use Spotify data to train machine learning models.
