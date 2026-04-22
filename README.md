<p align="center">
  <img src="assets/tv.svg" alt="media-cli" width="180" />
</p>

<p align="center">
  <h1 align="center">📺 media-cli</h1>
  <p align="center">
    Drive your self-hosted media stack from the terminal. One bash script, no runtime, works locally or over SSH.
    <br />
    <strong>Sonarr · Radarr · Prowlarr · qBittorrent · Bazarr · Jellyseerr · Tdarr</strong>
  </p>
</p>

<p align="center">
  <a href="https://github.com/solomonneas/media-cli/actions/workflows/ci.yml"><img src="https://github.com/solomonneas/media-cli/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://www.npmjs.com/package/@solomonneas/media-cli"><img src="https://img.shields.io/npm/v/@solomonneas/media-cli.svg" alt="npm"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <img src="https://img.shields.io/badge/shell-bash-green.svg" alt="Bash">
</p>

<p align="center">
  <a href="#install">Install</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#commands">Commands</a> •
  <a href="#malware-hardening">Hardening</a> •
  <a href="#ai-agent-integration">AI Agents</a> •
  <a href="#connection-modes">Remote/SSH</a>
</p>

---

**media-cli** is a single bash script that wraps the APIs of your entire media automation stack into simple, memorable commands. No Docker, no Node, no Python packages. Just `curl`, `python3` (stdlib only), and your existing *arr setup.

Built for humans who manage media servers from the terminal, and for AI agents that do it on their behalf.

**Playback server?** media-cli handles acquisition (Sonarr/Radarr/qBittorrent/Tdarr). For controlling Jellyfin itself (playback sessions, library scans, user management, scheduled tasks), see [**jellyfin-mcp**](https://github.com/solomonneas/jellyfin-mcp), the companion MCP server.

> Briefly shipped as `arr-cli`. The old GitHub URL still redirects, the `arr-cli` npm package stays installable, and the binary has always been `media`.

```bash
$ media movies search "Interstellar"
 [157336] Interstellar (2014) 169min
    The adventures of a group of explorers who make use of a newly discovered wormhole...

$ media movies add "Interstellar"
✅ Added: Interstellar (2014) - Searching for downloads...

$ media downloads active
[  23.4%] Interstellar.2014.1080p.BluRay.x265  (4.2 MB/s) 12m
```

## Supported Services

| Service | Status | What it does |
|---------|--------|-------------|
| [Sonarr](https://sonarr.tv) | Required | TV show search, add, monitor, manage |
| [Radarr](https://radarr.video) | Required | Movie search, add, monitor, manage |
| [Prowlarr](https://prowlarr.com) | Required | Indexer status and management |
| [qBittorrent](https://www.qbittorrent.org) | Required | Download monitoring and control |
| [Readarr](https://readarr.com) | Optional | Audiobooks and ebooks (two-instance deployment supported) |
| [Lidarr](https://lidarr.audio) | Optional | Music libraries (artist-first) |
| [Mylar3](https://github.com/mylar3/mylar3) | Optional | Comics, ComicVine-backed |
| [Bazarr](https://www.bazarr.media) | Optional | Subtitle status and history |
| [Jellyseerr](https://github.com/Fallenbagel/jellyseerr) | Optional | User requests and trending content |
| [Tdarr](https://tdarr.io) | Optional | Transcode monitoring (GPU/CPU worker progress) |
| [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) | Optional | Cloudflare challenge proxy for Prowlarr indexers |
| [Autobrr](https://autobrr.com) | Optional | IRC announce parser; feeds grabs to *arrs and qBit faster than RSS |
| [cross-seed](https://www.cross-seed.org) | Optional | Finds matching releases across trackers to cross-seed existing torrents |
| [Unpackerr](https://unpackerr.zip) | Optional | Extracts `.rar` releases so *arrs can import them |
| [Recyclarr](https://recyclarr.dev) | Optional | Syncs TRaSH-guide custom formats and quality profiles into Sonarr/Radarr |

## Requirements

- `bash` 4.0+
- `curl`
- `python3` (standard library only, no pip)
- `ssh` (only if using remote mode)

## Install

**npm (recommended):**

```bash
npm install -g @solomonneas/media-cli
```

Exposes both `media` and `media-cli` on your `PATH`. The package is scoped because the unscoped `media-cli` name on npm is taken by an unrelated project.

**One-liner (no npm):**

```bash
curl -fsSL https://raw.githubusercontent.com/solomonneas/media-cli/main/media -o ~/bin/media && chmod +x ~/bin/media
```

**Clone:**

```bash
git clone https://github.com/solomonneas/media-cli.git
cd media-cli
bash install.sh
```

Make sure `~/bin` (or whichever dir you installed to) is in your `PATH`.

## Quick Start

```bash
# 1. Run the setup wizard
media setup

# 2. Test your connection
media status

# 3. Start using it
media movies search "The Matrix"
media shows add "Breaking Bad"
media downloads active
```

The setup wizard asks for your API URLs and keys, then saves everything to `~/.config/media-cli/config`. You can also copy `config.example` and edit it by hand.

### Finding Your API Keys

| Service | Where to find it |
|---------|-----------------|
| Sonarr | Settings > General > API Key |
| Radarr | Settings > General > API Key |
| Prowlarr | Settings > General > API Key |
| Readarr (audiobooks + ebooks) | Settings > General > API Key, per instance |
| Lidarr | Settings > General > API Key |
| Mylar3 | Settings > Web Interface > API Key (query-param auth, not `X-Api-Key`) |
| Bazarr | Settings > General > API Key |
| Jellyseerr | Settings > General > API Key |
| Autobrr | Settings > API Keys > Create; sent as `X-API-Token` header |
| qBittorrent | Settings > Web UI > Username/Password |
| cross-seed | `cross-seed api-key` CLI; sent as `?apikey=` query param or `X-Api-Key` header |

Or grab them from the config files directly:

```bash
# Linux
grep -i apikey ~/.config/Sonarr/config.xml
grep -i apikey ~/.config/Radarr/config.xml

# Windows
type C:\ProgramData\Sonarr\config.xml | findstr ApiKey

# Docker
docker exec sonarr cat /config/config.xml | grep ApiKey
```

## Commands

### Library

```bash
# Movies (Radarr)
media movies list              # List all movies with download status
media movies search "title"    # Search online
media movies add "title"       # Add top result + start downloading
media movies remove "title"    # Remove from library (keeps files)
media movies missing           # Monitored movies without files

# TV Shows (Sonarr)
media shows list               # List all shows with episode counts
media shows search "title"     # Search online
media shows add "title"        # Add top result + search for episodes
media shows remove "title"     # Remove from library (keeps files)

# Audiobooks (Readarr primary instance)
media audiobooks list
media audiobooks search "Project Hail Mary"
media audiobooks add "Project Hail Mary"
media audiobooks missing
media audiobooks remove "title or author substring"

# Ebooks (Readarr second instance - set READARR_EBOOKS_URL / _KEY)
media ebooks list
media ebooks search "Pale Fire"
media ebooks add "Pale Fire"
media ebooks missing

# Music (Lidarr, artist-first)
media music list
media music search "Kendrick Lamar"
media music add "Kendrick Lamar"           # monitors all albums
media music missing
media music remove "artist substring"

# Comics (Mylar3, ComicVine-backed)
media comics list
media comics search "Saga"                  # returns CV IDs
media comics add <comicvine_id>             # add by CV ID (two-step flow)
media comics missing
media comics remove "series substring"
```

Readarr ships as two separate instances (it treats audiobooks + ebooks as one library otherwise). Point `READARR_URL` / `READARR_KEY` at the audiobooks instance and `READARR_EBOOKS_URL` / `READARR_EBOOKS_KEY` at the ebooks one.

### Downloads

```bash
media downloads                # List all torrents grouped by state
media downloads active         # Active downloads with speed + ETA
media downloads pause <hash|all>
media downloads resume <hash|all>
media downloads remove <hash> [true]   # true = also delete files
```

### Monitoring

```bash
media status                   # Service health + library counts + active downloads
media queue                    # Sonarr/Radarr download queues
media wanted                   # Missing episodes and movies
media calendar [days]          # Upcoming releases (default: 7 days)
media history [sonarr|radarr|all] [limit]
media indexers                 # List Prowlarr indexers
media refresh [movies|shows|all]   # Trigger library rescan
```

### Subtitles (Bazarr)

```bash
media subs                     # Wanted subtitles for movies + episodes
media subs history             # Recent subtitle downloads
```

### Requests (Jellyseerr)

```bash
media requests                 # Pending user requests
media requests trending        # What's trending
media requests users           # User list with request counts
```

### Transcoding (Tdarr)

```bash
media tdarr                    # Status, resources, active workers
media tdarr workers            # Per-file progress: %, fps, size reduction, ETA
media tdarr queue              # Items queued for processing

# Control
media tdarr boost on           # Disable schedule + set 3 GPU workers (burn through queue)
media tdarr boost off          # Re-enable schedule (restore time-based rotation)
media tdarr boost              # Show current state
media tdarr schedule on|off    # Enable/disable Tdarr's time-based schedule
media tdarr workers set transcodegpu 3   # Set worker limit for a type
                               # types: transcodegpu, transcodecpu, healthcheckgpu, healthcheckcpu
```

`boost on` is the "I want this library re-encoded by morning" button. It flips `scheduleEnabled=false` and maxes `workerLimits.transcodegpu` to 3 (override with `TDARR_BOOST_GPU_WORKERS=5 media tdarr boost on`). `boost off` re-enables the schedule; your usual day/night rotation resumes.

### Security (qBittorrent)

```bash
media qbit harden on           # Enable malware extension blocking (default after setup)
media qbit harden off          # Disable
media qbit harden status       # Show current state + blocked extensions
```

See [Malware Hardening](#malware-hardening) below for the full story.

### Cloudflare (FlareSolverr)

Prowlarr relies on [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) to pass Cloudflare's "checking your browser" challenge on indexers. When Prowlarr indexer tests start failing mysteriously, FlareSolverr is usually the culprit — either unreachable or its session cache has gone stale.

```bash
media flaresolverr               # Status + version + active session count
media flaresolverr sessions      # List active sessions
media flaresolverr test <url>    # Solve a challenge against a URL (triage)
media flaresolverr clear         # Destroy all sessions (reset stale state)
media flaresolverr clear <id>    # Destroy a specific session
```

Typical triage when an indexer test fails in Prowlarr:

```bash
media flaresolverr                           # Is the service up?
media flaresolverr test https://1337x.to     # Can it actually solve a challenge?
media flaresolverr clear                     # If sessions look stale, nuke them
```

`clear` is safe - FlareSolverr re-creates sessions on demand; Prowlarr reconnects automatically on the next request.

### Missing-items hunt

Loops through Sonarr / Radarr / Lidarr / Readarr (audiobooks + ebooks) and forces re-searches for monitored items that are still missing. Replaces the manual "click Search Monitored on every app" ritual and the now-retired Huntarr daemon (upstream was pulled in Feb 2026 over unpatched security issues).

```bash
media hunt run                       # One cycle across all enabled apps
media hunt run sonarr                # One cycle, one app (sonarr|radarr|music|audiobooks|ebooks)
media hunt status                    # Per-app last-run time + running totals
media hunt missing                   # Dry-run: missing count per app, no API writes
media hunt config                    # Active config (limits, cooldowns, state file path)
```

Rate-limited by design so indexers aren't hammered: `HUNT_MISSING_PER_CYCLE` items per app per cycle (default 5), `HUNT_API_DELAY_SECONDS` between API calls (default 10), `HUNT_MIN_INTERVAL_MINUTES` cooldown between cycles of the same app (default 30). Drop `media hunt run` into cron / Task Scheduler on whatever cadence you want; cooldowns make double-triggering safe.

### Autobrr

[Autobrr](https://autobrr.com) watches IRC announce channels and pushes matching releases to the *arrs or qBit faster than RSS can. Writes (filters, IRC networks, credentials) stay in the web UI - this is a read-only surface.

```bash
media autobrr status                 # Version, filter/client/IRC counts, release total
media autobrr filters                # List filters with id, enabled, priority, action count
media autobrr irc                    # IRC networks and connection state
media autobrr clients                # *arr download clients pointed at by filters
media autobrr releases [limit]       # Recent releases seen (default 20)
```

Config: `AUTOBRR_URL`, `AUTOBRR_KEY` (X-API-Token header auth).

### Cross-seed

[cross-seed v6](https://www.cross-seed.org) finds matching releases across trackers and cross-seeds them via qBit. The CLI wraps the daemon's REST API and pulls match counts from the on-disk log.

```bash
media crossseed status               # Daemon ping, log-derived match counts, outputDir size
media crossseed log [N]              # Tail N lines of today's info log (default 30)
media crossseed search               # Force an immediate search-job sweep
media crossseed rss                  # Force an immediate RSS scan
media crossseed inject               # Process saved .torrent files into qBit (save -> inject bridge)
media crossseed cleanup              # Run housekeeping job
media crossseed config               # Key config.js fields + torznab feed count
```

Two operating modes, set in `config.js`:

- `action: "save"` - first-run posture. Matches are written as `.torrent` files to `outputDir`, reviewed, then piped to qBit with `media crossseed inject`.
- `action: "inject"` - matches go straight into qBit under `linkCategory`. Requires `linkDirs` on hardlink-capable filesystems (NTFS / ext4 / APFS / Btrfs); exFAT will not work because hardlinks aren't supported on exFAT.

Config env vars: `CROSSSEED_URL` (default `http://localhost:2468`), `CROSSSEED_KEY`, `CROSSSEED_LOGDIR`, `CROSSSEED_CONFIG`. Alias: `media xseed`.

### Unpackerr

[Unpackerr](https://unpackerr.zip) watches the *arrs and extracts `.rar` releases so imports stop silently stalling. There's no HTTP API, so the CLI reads the log directly.

```bash
media unpackerr status               # Queue counts + totals (default)
media unpackerr recent [N]           # Last N per-item status lines (default 25)
media unpackerr waiting               # Items stuck as "completed but no extractable files"
media unpackerr log [N]              # Raw log tail (default 50)
```

Config: `UNPACKERR_LOG` pointing at the daemon's logfile (`.log`). Alias: `media unpack`.

### Recyclarr

[Recyclarr](https://recyclarr.dev) syncs [TRaSH guide](https://trash-guides.info) custom formats and quality profiles into Sonarr and Radarr so your naming + scoring matches community best practice. The CLI is a thin wrapper so common flows are one verb.

```bash
media recyclarr status               # Binary path, config path, recyclarr version
media recyclarr diff                 # Dry-run sync (alias: preview)
media recyclarr sync                 # Apply config to Sonarr/Radarr
media recyclarr list formats [svc]   # TRaSH custom formats (svc = sonarr|radarr, default sonarr)
media recyclarr list profiles [svc]  # TRaSH quality profiles
media recyclarr list naming [svc]    # Media naming formats
media recyclarr list templates       # Local config templates
media recyclarr config               # Print the active recyclarr.yml
```

Config: `RECYCLARR_BIN` (path to binary; defaults to PATH lookup), `RECYCLARR_CONFIG` (path to `recyclarr.yml`). Alias: `media trash`.

## Connection Modes

### Local Mode

Services run on the same machine as the CLI:

```bash
MEDIA_HOST="local"
```

### SSH Mode

Services run on a remote host (NAS, dedicated server, Windows box) and bind to `localhost`. The CLI runs curl commands over SSH:

```bash
MEDIA_HOST="ssh:mediaserver"     # Uses your SSH config alias
MEDIA_HOST_OS="linux"            # or "windows"
```

This is the killer feature for headless servers. Your services don't need to be exposed to the network. The CLI tunnels everything through SSH.

**Windows hosts work too.** POST requests automatically use PowerShell's `Invoke-RestMethod` when `MEDIA_HOST_OS="windows"`, so you don't need curl installed on the Windows side.

## AI Agent Integration

This CLI was built alongside [OpenClaw](https://openclaw.ai), an AI agent platform. The commands are designed to be easily parsed by AI assistants.

Any AI agent or automation tool that can run shell commands can use media-cli:

**Natural language to commands:**

> "What shows am I missing episodes for?"
```bash
media wanted
```

> "Add Succession and start downloading it"
```bash
media shows add "Succession"
```

> "What's actively downloading right now?"
```bash
media downloads active
```

> "Pause all downloads"
```bash
media downloads pause all
```

Works with OpenClaw, LangChain tool calling, Claude computer use, or any agent framework that supports shell execution.

## How It Works

```
                       ┌──────────────┐
                       │  media-cli   │
                       │  (your box)  │
                       └──────┬───────┘
                              │  curl (over SSH, optional)
                              ▼
        ┌──────────────┬──────┴───────┬──────────────┐
        ▼              ▼              ▼              ▼
  ┌──────────┐   ┌──────────┐   ┌──────────┐
  │  Sonarr  │   │  Radarr  │   │ Prowlarr │
  │  :8989   │   │  :7878   │   │  :9696   │
  └────┬─────┘   └────┬─────┘   └──────────┘
       │              │
       └──────┬───────┘
              ▼
       ┌─────────────┐
       │ qBittorrent │
       │    :8080    │
       └──────┬──────┘
              │
     ┌────────┼────────┐
     ▼        ▼        ▼
┌──────────┐┌──────────┐┌──────────┐
│  Bazarr  ││Jellyseerr││  Tdarr   │
│  :6767   ││  :5055   ││  :8265   │
└──────────┘└──────────┘└──────────┘
```

Optional services attach to the same spine:

- **Readarr** (audiobooks + ebooks, two instances): `:8787` / `:8788`
- **Lidarr** (music): `:8686`
- **Mylar3** (comics): `:8090`
- **Autobrr** (IRC announce): `:7474`
- **cross-seed** daemon: `:2468`
- **Unpackerr**: no HTTP, reads log
- **Recyclarr**: local binary, no HTTP
- **FlareSolverr** (Cloudflare solver for Prowlarr): `:8191`

Facts:

- Single bash script (~3,100 lines), no external package dependencies
- Talks to Servarr v3 APIs (Sonarr / Radarr), v1 (Prowlarr / Readarr / Lidarr), v2 (qBittorrent WebUI), plus a handful of service-specific REST surfaces (Autobrr, cross-seed, FlareSolverr)
- Python3 is used strictly for JSON parsing (standard library only)
- Config file is stored at `~/.config/media-cli/config` with `chmod 600`
- No telemetry, no analytics, no network calls except to your own services

## Malware Hardening

Poisoned `*arr` releases are a real thing. In April 2026 a wave of them shipped LummaStealer-class payloads as fake video-named `.exe` / `.scr` files inside releases for popular shows. Legit video releases do not contain executables.

media-cli ships a one-command hardening layer that sets qBittorrent's global `excluded_file_names` preference so these files never hit disk:

```bash
media qbit harden on        # Enabled by default after `media setup`
media qbit harden off       # Opt out
media qbit harden status    # Inspect current state
```

**Blocked by default:**

```text
*.scr *.pif *.vbs *.wsf *.hta *.lnk *.jar *.com *.msi
*.js *.jse *.vbe *.ps1 *.psm1 *.reg *.dll
```

**Deliberately NOT blocked:** `.exe` and `.bat`. Some qBittorrent users legitimately download non-media content that needs these (game installers, etc.). If you only use qB for media, add them:

```bash
QBIT_HARDEN_EXTRAS="*.exe *.bat" media qbit harden on
```

**This is one layer of three.** For a full defense-in-depth stack on a Windows media host you also want:

1. **Windows Defender exclusions + real-time scanning on your downloads directory.** Don't disable Defender for your whole drive; just exclude the specific legit-but-false-positive paths you know about.
2. **qB autorun hook that deletes executables in media-category torrents only.** qBittorrent can run a command "on torrent completed" — point it at a script that walks the completed torrent and deletes any executables if the category is your Sonarr/Radarr category. That way manual downloads in other categories aren't touched.

media-cli doesn't automate these two - they're host-OS-specific and the right paths/categories depend on your setup. The CLI handles the one layer that's cleanly API-addressable across platforms (qBittorrent's own preference).

**Preserves your existing exclusions.** `harden on` merges our patterns into whatever `excluded_file_names` list qBittorrent already has; your custom exclusions survive. `harden off` removes *only* our patterns, leaving yours intact. The feature toggle flips off only if nothing user-authored remains.

## Hiding Console Popups (Windows)

Most *arr services shipped as Windows scheduled tasks pop a console window on boot or on every scheduled run, because Task Scheduler launches them in the user's interactive session. PowerShell's `-WindowStyle Hidden` still flashes briefly; the only truly flash-free path is to route the action through `wscript.exe`, which is a GUI-subsystem binary and never opens a console.

media-cli ships `assets/launch-hidden.vbs` and `scripts/hide-task-popups.ps1` for this. The VBS re-emits the target command line with `WshShell.Run showStyle=0` (SW_HIDE), and the retrofit script rewrites existing scheduled tasks to invoke the VBS instead of the target exe directly.

```powershell
# Dry-run the curated default set (all *arr + common support services)
powershell.exe -ExecutionPolicy Bypass -File scripts\hide-task-popups.ps1 -All -DryRun

# Apply for real (needs Administrator; most *arr task files are Admin-owned)
powershell.exe -ExecutionPolicy Bypass -File scripts\hide-task-popups.ps1 -All

# Target specific tasks
powershell.exe -ExecutionPolicy Bypass -File scripts\hide-task-popups.ps1 -TaskName Sonarr,Radarr,Bazarr

# Revert a task to its original action
powershell.exe -ExecutionPolicy Bypass -File scripts\hide-task-popups.ps1 -TaskName Sonarr -Unwrap
```

The script is idempotent. Before modifying a task it exports the current XML to `$env:LOCALAPPDATA\arr-cli\task-backups-<timestamp>\` so manual rollback via `schtasks /create /xml` is always available. Tasks already invoking their own VBS wrapper are detected and skipped rather than double-wrapped.

**Known exceptions:**

- **Password-logon tasks** (e.g. FlareSolverr's `LogonType: Password`): `Set-ScheduledTask` re-authenticates the stored credential when the action changes, and fails with `ERROR_LOGON_FAILURE` if the password is no longer valid. These tasks must be unwrapped by hand (or re-registered with a fresh credential) - skip them with `-TaskName` if you hit this.
- **Hidden background state:** after wrap, the target service runs as a grandchild of wscript rather than a direct child. Task Scheduler's "Stop the task" button will stop the wscript invoker (already exited), not the service. Stop the service directly (`Stop-Process`, systemd-on-Windows, etc.).

## License

[MIT](LICENSE)
