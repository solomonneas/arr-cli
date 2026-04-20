<p align="center">
  <h1 align="center">🏴‍☠️ arr-cli</h1>
  <p align="center">
    Plunder your *arr media stack from the terminal. One bash script, no runtime, works locally or over SSH.
    <br />
    <strong>Sonarr · Radarr · Prowlarr · qBittorrent · Bazarr · Jellyseerr · Tdarr</strong>
  </p>
</p>

<p align="center">
  <a href="https://github.com/solomonneas/arr-cli/actions/workflows/ci.yml"><img src="https://github.com/solomonneas/arr-cli/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://www.npmjs.com/package/arr-cli"><img src="https://img.shields.io/npm/v/arr-cli.svg" alt="npm"></a>
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

**arr-cli** is a single bash script that wraps the APIs of your entire media automation stack into simple, memorable commands. No Docker, no Node, no Python packages. Just `curl`, `python3` (stdlib only), and your existing *arr setup.

Built for humans who manage media servers from the terminal, and for AI agents that do it on their behalf.

**Playback server?** arr-cli handles acquisition (Sonarr/Radarr/qBittorrent/Tdarr). For controlling Jellyfin itself — playback sessions, library scans, user management, scheduled tasks — see [**jellyfin-mcp**](https://github.com/solomonneas/jellyfin-mcp), the companion MCP server.

> Formerly `media-cli`. Old GitHub URL still redirects. The binary is still named `media` (also installed as `arr-cli`), and the config path stays at `~/.config/media-cli/` for back-compat.

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
| [Bazarr](https://www.bazarr.media) | Optional | Subtitle status and history |
| [Jellyseerr](https://github.com/Fallenbagel/jellyseerr) | Optional | User requests and trending content |
| [Tdarr](https://tdarr.io) | Optional | Transcode monitoring (GPU/CPU worker progress) |

## Requirements

- `bash` 4.0+
- `curl`
- `python3` (standard library only, no pip)
- `ssh` (only if using remote mode)

## Install

**npm (recommended):**

```bash
npm install -g arr-cli
```

Exposes both `arr-cli` and `media` on your `PATH`.

**One-liner (no npm):**

```bash
curl -fsSL https://raw.githubusercontent.com/solomonneas/arr-cli/main/media -o ~/bin/media && chmod +x ~/bin/media
```

**Clone:**

```bash
git clone https://github.com/solomonneas/arr-cli.git
cd arr-cli
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
| Bazarr | Settings > General > API Key |
| Jellyseerr | Settings > General > API Key |
| qBittorrent | Settings > Web UI > Username/Password |

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
media movies list              # List all movies with download status
media movies search "title"    # Search online (via Radarr)
media movies add "title"       # Add top result + start downloading
media movies remove "title"    # Remove from library (keeps files)
media movies missing           # Show monitored movies without files

media shows list               # List all shows with episode counts
media shows search "title"     # Search online (via Sonarr)
media shows add "title"        # Add top result + search for episodes
media shows remove "title"     # Remove from library (keeps files)
```

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

Any AI agent or automation tool that can run shell commands can use arr-cli:

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
                       │   arr-cli    │
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

- Single bash script (~900 lines), no external dependencies
- Talks to *arr v3 APIs (Sonarr/Radarr), v1 (Prowlarr), v2 (qBittorrent WebUI)
- Python3 is used strictly for JSON parsing (standard library only)
- Config file is stored at `~/.config/media-cli/config` with `chmod 600`
- No telemetry, no analytics, no network calls except to your own services

## Malware Hardening

Poisoned `*arr` releases are a real thing. In April 2026 a wave of them shipped LummaStealer-class payloads as fake video-named `.exe` / `.scr` files inside releases for popular shows. Legit video releases do not contain executables.

arr-cli ships a one-command hardening layer that sets qBittorrent's global `excluded_file_names` preference so these files never hit disk:

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

arr-cli doesn't automate these two — they're host-OS-specific and the right paths/categories depend on your setup. The CLI handles the one layer that's cleanly API-addressable across platforms (qBittorrent's own preference).

**Preserves your existing exclusions.** `harden on` merges our patterns into whatever `excluded_file_names` list qBittorrent already has; your custom exclusions survive. `harden off` removes *only* our patterns, leaving yours intact. The feature toggle flips off only if nothing user-authored remains.

## License

[MIT](LICENSE)
