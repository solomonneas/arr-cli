# Roadmap

Planned additions to arr-cli. Nothing here is in the script yet. Ordered roughly by priority within each section.

Contributions welcome. If you're picking something up, open an issue first so we don't double-dip.

## Content Acquisition

Next *arr apps to wrap. All three follow the same pattern as Sonarr/Radarr: Servarr-family v1 JSON API, API key under Settings > General, and a familiar `list / search / add / remove / missing` surface.

### Readarr

Ebooks and audiobooks. Two separate Readarr instances are the usual deployment (one per media type) because Readarr treats them as one library otherwise.

```bash
media books list
media books search "Project Hail Mary"
media books add "Project Hail Mary"
media books missing

media audiobooks list
media audiobooks add "Dune"
```

- Readarr is officially in maintenance limbo. `readarr-develop` Docker tag is the actively patched line.
- Config needs `READARR_BOOKS_URL` + `READARR_BOOKS_KEY` and optionally `READARR_AUDIOBOOKS_URL` + `READARR_AUDIOBOOKS_KEY`.

### Lidarr

Music. Artist-first instead of album-first, so the verbs shift slightly.

```bash
media music list
media music search "Kendrick Lamar"
media music add "Kendrick Lamar"          # adds artist, monitors all albums
media music add "To Pimp A Butterfly"     # adds single album
media music missing
```

### Mylar3

Comics. API is token-based rather than api-key-header, so the auth helper needs a small branch.

```bash
media comics list
media comics search "Saga"
media comics add "Saga"
media comics missing
```

- Mylar3's API is less uniform than the *arr family. Expect a thinner initial command set.

## Stack Quality

Not acquisition apps. Things that make the stack self-healing, self-tuning, or less annoying to operate. arr-cli wraps them where there's a clean API surface; some are intentionally thin passthroughs.

### Recyclarr

Syncs TRaSH-guide custom formats and quality profiles into Sonarr and Radarr. Already a CLI, so arr-cli's job is to make the common flows one verb.

```bash
media recyclarr sync              # recyclarr sync
media recyclarr diff              # recyclarr diff (dry run)
media recyclarr list templates    # available TRaSH templates
```

- Shells out to a local `recyclarr` binary. Installs via its own container or the distributed binary.

### Profilarr

Web-UI / API alternative to Recyclarr. Same goal, different distribution model. Pick one, not both.

```bash
media profilarr status
media profilarr sync
```

### Huntarr

Loops through Sonarr / Radarr / Lidarr / Readarr and forces re-searches for missing and cutoff-unmet items. Replaces the manual "click every 'Search Monitored' button" ritual.

```bash
media huntarr status
media huntarr run [sonarr|radarr|all]
media huntarr stats
```

### Notifiarr

Notification hub with a Discord focus. Two uses from arr-cli:

1. Read: pull recent notifications across all *arrs in one feed.
2. Write: send ad-hoc notifications from scripts.

```bash
media notifiarr recent
media notifiarr send "Library backup complete"
```

### Cross-seed

Finds matching releases across trackers and cross-seeds them via qBittorrent. Has a daemon mode with a REST API.

```bash
media cross-seed status
media cross-seed search <hash|all>     # on-demand cross-seed search
media cross-seed recent                 # recent matches
```

### Autobrr

IRC announce parser that feeds grabs to *arrs and qBit faster than RSS. Has a first-class REST API.

```bash
media autobrr status
media autobrr filters                   # list filters + match counts
media autobrr recent                    # recent releases matched
```

### Unpackerr

Extracts `.rar` releases so *arrs can import them. Mostly set-and-forget, but a status verb is useful when imports silently stall.

```bash
media unpackerr status                  # queue + recent extractions
media unpackerr recent
```

## Not Planned

For clarity, things that get asked about but won't land here:

- **Ombi** - Jellyseerr is already covered; Ombi would be a duplicate surface.
- **Sabnzbd / NZBGet** - arr-cli is torrent-first by design. A `media usenet` namespace could happen if there's real demand, but it's not on the roadmap today.
- **Plex** - See [jellyfin-mcp](https://github.com/solomonneas/jellyfin-mcp) for the playback side. Plex is out of scope.

## How to Propose Changes

Open an issue with `roadmap:` in the title, or a PR editing this file. Low bar, just argue for it.
