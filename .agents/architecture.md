# Architecture

## Repository layout

```
remove-ai-watermarks-KDE/
├── install.sh      # Self-contained installer (heredoc-based)
├── uninstall.sh    # Self-contained uninstaller
├── README.md       # User-facing docs (English)
├── agents.md       # Agent orientation (this doc set)
└── .agents/        # Detailed documentation
```

## What gets installed

All paths derive from `DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"`.

| File | Role |
|---|---|
| `$DATA_DIR/remove-ai-watermarks-kde/raiw-helper.sh` | Helper executed by the menus; runs the CLI, names outputs, notifies |
| `$DATA_DIR/kio/servicemenus/remove-ai-watermarks.desktop` | Single-image menu: `identify`, `visible`, `metadata`, `all` |
| `$DATA_DIR/kio/servicemenus/remove-ai-watermarks-batch.desktop` | Batch menu for 2+ selected images (`X-KDE-MinNumberOfUrls=2`), action `batch` |
| `$DATA_DIR/kio/servicemenus/remove-ai-watermarks-folders.desktop` | Folder menu (`MimeType=inode/directory`), action `batch` |
| `$DATA_DIR/remove-ai-watermarks-kde/raiw.log` | Diagnostic log, appended on every event |

## Execution flow

```
User right-clicks image in Dolphin
  → KDE ServiceMenu (remove-ai-watermarks.desktop) matches image/*
  → KDE runs: raiw-helper.sh <mode> <file>...
      ├─ resolve CLI: RAIW="$(command -v remove-ai-watermarks || true)"
      ├─ localize messages from $LANG (see localization.md)
      ├─ per target:
      │    ├─ directory + mode=batch  → batch_dir (level-1 images only)
      │    ├─ directory + other mode  → error "use Batch process"
      │    ├─ file + mode=batch       → process_one visible
      │    └─ file + other mode       → process_one <mode>
      ├─ identify: accumulate report → <name>_ai_analysis.txt → open_file
      └─ other modes: kdialog passivepopup summary (done / errors)
```

## ServiceMenu format contract

- `Type=Service`, `ServiceTypes=KFileItemActions/Plugin;KonqPopupMenu/Plugin;`
- `X-KDE-Submenu=Remove AI Watermarks` — groups all three menus under one
  submenu; `X-KDE-Priority=TopLevel` keeps it at the top level.
- `Exec="$HELPER" <mode> %F` — `%F` passes all selected files (quoted).
- Every action has `Name`, `Name[pt]`, `Name[es]` and an `Icon`.
- The helper and all `.desktop` files are `chmod +x` — KDE refuses to execute
  ServiceMenus without the executable bit.

## Naming contracts (do not change)

| Context | Pattern | Example |
|---|---|---|
| Cleaned output | `<dir>/<stem>_ai_cleaned.<ext>` | `photo_ai_cleaned.jpg` |
| No-extension file | `<dir>/<name>_ai_cleaned` | `photo_ai_cleaned` |
| Identify report | `<dir>/<stem>_ai_analysis.txt` | `photo_ai_analysis.txt` |

`out_name()` splits on the **last** dot (`${base##*.}` / `${base%.*}`).
`batch_dir()` skips any file whose basename matches `*_ai_cleaned.*` so
re-running a batch never reprocesses our own outputs.

## Batch logic

- `batch_dir` uses `find "$dir" -maxdepth 1 -type f -print0` (level 1 only,
  no recursion) and filters with `is_image()`:
  `jpg jpeg png webp bmp tif tiff` (explicit upper/lowercase variants).
- Batch always runs the `visible` mode.
- Counting: `processed` increments per file target; `errors` increments per
  failed file. The final popup reports `%s file(s) processed successfully.`
  or `%s file(s) failed (%s processed). See terminal for details.`

## Error handling & logging

- Helper runs with `set -u` (not `-e` — failures are counted, not fatal).
- Every code path logs to `raiw.log` via `log()` (`date '+%F %T'` prefix);
  logging itself never fails the script (`|| true`).
- `notify()` prefers `kdialog --passivepopup <msg> 5`; on missing kdialog it
  logs and continues.
- Exit codes: `2` for usage errors (no mode / no files / folder with wrong
  mode), `1` for missing CLI, `0` after processing (even with per-file errors).

## Installer / uninstaller mechanics

- `install.sh`: verify CLI presence (warning only) → `mkdir -p` → write helper
  via quoted heredoc (`<<'HELPER_EOF'` — no expansion) → write three `.desktop`
  files via unquoted heredocs (expand `$HELPER`) → `chmod +x` → refresh cache
  (`kbuildsycoca6` → `kbuildsycoca5` fallback).
- `uninstall.sh`: remove the three `.desktop` files, remove the app dir
  (`rm -rf`), refresh cache. Never touches the CLI tool or `_ai_cleaned`
  outputs.
- Both are idempotent and safe to re-run.