# hide-task-popups.ps1
# Retrofit Windows scheduled tasks so their action launches through a
# hidden-window VBS wrapper (assets/launch-hidden.vbs). Result: no
# console flash on boot or run.
#
# Usage:
#   powershell.exe -File .\hide-task-popups.ps1 -TaskName Sonarr,Radarr
#   powershell.exe -File .\hide-task-popups.ps1 -All
#   powershell.exe -File .\hide-task-popups.ps1 -All -DryRun
#   powershell.exe -File .\hide-task-popups.ps1 -Unwrap -TaskName Sonarr
#
# The script is idempotent: already-wrapped tasks are detected and skipped.

[CmdletBinding()]
param(
    [string[]]$TaskName = @(),
    [switch]$All,
    [switch]$DryRun,
    [switch]$Unwrap
)

$ErrorActionPreference = 'Stop'

# Curated default set: user-facing *arr and support services whose tasks
# currently pop consoles on this style of install. Tasks that already
# run headless (MS store apps, system services) are intentionally out.
$DefaultTargets = @(
    'Bazarr','Prowlarr','Sonarr','Radarr','Readarr','ReadarrEbooks','Lidarr','Mylar3',
    'autobrr','cross-seed','Jellyseerr','Homepage','Stash',
    'Tdarr_Node','Tdarr_Server','Unpackerr','StartQBittorrentAfterMullvad',
    'HuntCycle','JellyfinWatchdog','HDriveWatchdog','MullvadWatchdog','DiskSpaceMonitor',
    'RecyclarrDaily','PatchJellyfinHEVC10bit','SyncNotesToObsidian','FlareSolverr'
)

if ($All) { $TaskName = $DefaultTargets }
if ($TaskName.Count -eq 0) {
    Write-Error 'Specify -TaskName <name>... or -All.'
    exit 1
}

# Install the VBS wrapper under LOCALAPPDATA so per-user task actions can
# reference a stable absolute path without needing admin rights.
$VbsDir  = Join-Path $env:LOCALAPPDATA 'arr-cli'
$VbsPath = Join-Path $VbsDir 'launch-hidden.vbs'
$RepoVbs = Join-Path $PSScriptRoot '..\assets\launch-hidden.vbs'

if (-not $Unwrap) {
    if (-not (Test-Path $RepoVbs)) {
        Write-Error "Can't find launch-hidden.vbs at $RepoVbs"
        exit 1
    }
    if (-not $DryRun) {
        New-Item -ItemType Directory -Force -Path $VbsDir | Out-Null
        Copy-Item -Force $RepoVbs $VbsPath
    }
    Write-Host "VBS wrapper: $VbsPath"
}

# Backup dir for original task XML - useful for manual rollback.
$BackupDir = Join-Path $VbsDir ('task-backups-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))

$wrapped = 0; $skipped = 0; $unwrapped = 0; $missing = 0

foreach ($name in $TaskName) {
    $task = Get-ScheduledTask -TaskName $name -ErrorAction SilentlyContinue
    if (-not $task) {
        Write-Warning "Task not found: $name"
        $missing++
        continue
    }

    # Unwrap path: restore original exe/args by parsing the wrapped action.
    if ($Unwrap) {
        $newActions = @()
        $anyChanged = $false
        foreach ($a in $task.Actions) {
            if ($a.Execute -ieq 'wscript.exe' -and $a.Arguments -match 'launch-hidden\.vbs') {
                # Arguments shape: "<vbs>" "<origExe>" <origArgs...>
                # Strip the two leading quoted tokens; the remainder is origArgs.
                # Reverse the "" -> \" transform applied at wrap time so the
                # restored args match what the task originally stored.
                if ($a.Arguments -match '^\s*"[^"]+"\s+"([^"]+)"\s*(.*)$') {
                    $origExe  = $Matches[1]
                    $origArgs = $Matches[2] -replace '""', '\"'
                    $act = New-ScheduledTaskAction -Execute $origExe -Argument $origArgs
                    if ($a.WorkingDirectory) { $act.WorkingDirectory = $a.WorkingDirectory }
                    $newActions += $act
                    $anyChanged = $true
                    Write-Host "  $name  unwrap -> $origExe $origArgs"
                } else {
                    Write-Warning "  $name  wrapped but args unparseable; leaving as-is"
                    $newActions += $a
                }
            } else {
                $newActions += $a
            }
        }
        if ($anyChanged -and -not $DryRun) {
            Set-ScheduledTask -TaskName $name -Action $newActions | Out-Null
            $unwrapped++
        } elseif (-not $anyChanged) {
            Write-Host "  $name  (not wrapped, skipping)"
            $skipped++
        }
        continue
    }

    # Wrap path.
    $newActions = @()
    $anyChanged = $false
    foreach ($a in $task.Actions) {
        if ($a.Execute -ieq 'wscript.exe' -and $a.Arguments -match 'launch-hidden\.vbs') {
            Write-Host "  $name  (already wrapped)"
            $newActions += $a
            continue
        }
        # wscript.exe is the Windows Script Host GUI runner; it never shows a
        # console itself. If a task already invokes wscript (with any .vbs),
        # some hiding scheme is already in place - re-wrapping just adds a
        # layer with no UX gain. Leave it alone.
        if ($a.Execute -ieq 'wscript.exe' -and $a.Arguments -match '\.vbs') {
            Write-Host "  $name  (already launches via wscript; skipping)"
            $newActions += $a
            continue
        }

        # Build the wrapper args: "<vbs>" "<origExe>" <origArgs...>
        #
        # wscript.exe's argv parser does not honor MSVCRT's \" escape, but
        # does honor the paired "" escape inside a quoted region. Tasks like
        # `bash -c "... \"$log\" ..."` store their args with \" escapes, so
        # we rewrite those to "" before handing the string to wscript. The
        # VBS wrapper then emits \" on the rebuild side, which the wrapped
        # target (MSVCRT-based) decodes back to a literal " - closing the
        # round trip.
        $origExe  = $a.Execute
        $origArgs = $a.Arguments
        $origWd   = $a.WorkingDirectory
        $wscriptSafeArgs = if ($origArgs) { $origArgs -replace '\\"', '""' } else { '' }
        $newArgs  = '"{0}" "{1}"' -f $VbsPath, $origExe
        if (-not [string]::IsNullOrWhiteSpace($wscriptSafeArgs)) {
            $newArgs = "$newArgs $wscriptSafeArgs"
        }

        $act = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument $newArgs
        if (-not [string]::IsNullOrWhiteSpace($origWd)) {
            $act.WorkingDirectory = $origWd
        }
        $newActions += $act
        $anyChanged = $true
        Write-Host "  $name"
        Write-Host "    was: $origExe $origArgs"
        Write-Host "    now: wscript.exe $newArgs"
    }

    if ($anyChanged) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
            Export-ScheduledTask -TaskName $name | Out-File -Encoding utf8 (Join-Path $BackupDir "$name.xml")
            Set-ScheduledTask -TaskName $name -Action $newActions | Out-Null
        }
        $wrapped++
    } else {
        $skipped++
    }
}

Write-Host ''
if ($Unwrap) {
    Write-Host "Unwrapped: $unwrapped  Skipped: $skipped  Missing: $missing"
} else {
    Write-Host "Wrapped: $wrapped  Skipped: $skipped  Missing: $missing"
    if ($wrapped -gt 0 -and -not $DryRun) {
        Write-Host "Task XML backups: $BackupDir"
    }
}
if ($DryRun) { Write-Host '(dry run - no changes applied)' }
