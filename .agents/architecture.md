# Architecture

## Repository layout

```
remove-ai-watermarks-contextmenu/
├── install.sh              # Main installer (dispatcher): detects DE + FMs, dispatches
├── uninstall.sh            # Main uninstaller (dispatcher): removes all integrations
├── install-deps.sh         # Installs the remove-ai-watermarks CLI + deps (distro-aware)
├── uninstall-deps.sh       # Removes the remove-ai-watermarks CLI
├── raiw-helper.sh          # Shared helper executed by the menus (single source of truth)
├── install-dolphin.sh      # KDE ServiceMenus installer
├── uninstall-dolphin.sh
├── install-nautilus.sh     # Nautilus scripts installer
├── uninstall-nautilus.sh
├── install-thunar.sh       # Thunar uca.xml installer
├── uninstall-thunar.sh
├── install-nemo.sh         # Nemo .nemo_action installer
├── uninstall-nemo.sh
├── install-caja.sh         # Caja scripts installer
├── uninstall-caja.sh
├── install-pcmanfm.sh      # PCManFM DES-EMA installer
├── uninstall-pcmanfm.sh
├── README.md               # User-facing docs (English)
├── agents.md               # Agent orientation (this doc set)
└── .agents/                # Detailed documentation
```

## Dispatcher flow (install.sh)

```
install.sh
  ├─ DE="${XDG_CURRENT_DESKTOP:-}"            # detection
  ├─ FMS=()                                   # command -v dolphin nautilus thunar nemo caja pcmanfm pcmanfm-qt
  │    └─ if empty → de_default_fm()          # KDE→dolphin, GNOME→nautilus, XFCE→thunar,
  │                                           #   *Cinnamon*→nemo, MATE→caja, LXDE/LXQt→pcmanfm
  ├─ --all flag → FMS=(all supported)
  ├─ deps (unless --no-deps): curl install-deps.sh | bash
  │    └─ uv (distro pkg → official) → python 3.12 → uv tool install remove-ai-watermarks[all]
  ├─ install shared helper (curl raiw-helper.sh → $APP_DIR, chmod +x)
  └─ for each fm: curl -fsSL $BASE_URL/install-<fm>.sh | bash
```

`uninstall.sh` calls every `uninstall-<fm>.sh` unconditionally (idempotent),
then removes `$APP_DIR`, then (with `--deps` or after a prompt) calls
`uninstall-deps.sh` to remove the CLI.

`BASE_URL="${RAIW_BASE_URL:-https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-contextmenu/main}"`
— `RAIW_BASE_URL` can be overridden for local testing (e.g. `file://$PWD`).

## What gets installed

All paths derive from `DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"`.

| File manager        | Files                                                                    |
| ------------------- | ------------------------------------------------------------------------ |
| Dolphin (KDE)       | `$DATA_DIR/kio/servicemenus/remove-ai-watermarks*.desktop` (3 files)     |
| Nautilus (GNOME)    | `$DATA_DIR/nautilus/scripts/Remove AI Watermarks/*` (5 scripts)          |
| Thunar (XFCE)       | `$XDG_CONFIG_HOME/Thunar/uca.xml` (adds `raiw-*` actions)                |
| Nemo (Cinnamon)     | `$DATA_DIR/nemo/actions/remove-ai-watermarks*.nemo_action` (5 files)     |
| Caja (MATE)         | `$DATA_DIR/caja/scripts/Remove AI Watermarks/*` (5 scripts)              |
| PCManFM (LXDE/LXQt) | `$DATA_DIR/file-manager/actions/remove-ai-watermarks*.desktop` (5 files) |
| Shared              | `$DATA_DIR/remove-ai-watermarks-kde/raiw-helper.sh` + `raiw.log`         |

## Execution flow (helper)

```
User right-clicks image in a file manager
  → native integration runs: raiw-helper.sh <mode> <file>...
      ├─ resolve CLI: RAIW="$(command -v remove-ai-watermarks || true)"
      ├─ localize messages from $LANG (see localization.md)
      ├─ per target:
      │    ├─ directory + mode=batch  → batch_dir (level-1 images only)
      │    ├─ directory + other mode  → error "use Batch process"
      │    ├─ file + mode=batch       → process_one visible
      │    └─ file + other mode       → process_one <mode>
      ├─ identify: accumulate report → <name>_ai_analysis.txt → open_file
      └─ other modes: notify summary (done / errors)
```

## Per-manager integration formats

### Dolphin (KDE) — ServiceMenus
- `Type=Service`, `ServiceTypes=KFileItemActions/Plugin;KonqPopupMenu/Plugin;`
- `X-KDE-Submenu=Remove AI Watermarks`, `X-KDE-Priority=TopLevel`
- `Exec="$HELPER" <mode> %F`
- 3 files: single-image (`identify`/`visible`/`metadata`/`all`), batch
  (`X-KDE-MinNumberOfUrls=2`, action `batch`), folders (`MimeType=inode/directory`, action `batch`)
- Refresh cache: `kbuildsycoca6` → `kbuildsycoca5`

### Nautilus (GNOME) — scripts
- Executable scripts in `$DATA_DIR/nautilus/scripts/Remove AI Watermarks/`
  (subfolder = submenu)
- Each script: `#!/usr/bin/env bash` + `exec "$HELPER" <mode> "$@"`
- Restart: `nautilus -q`

### Thunar (XFCE) — uca.xml
- `<action>` blocks with unique ids `raiw-identify/visible/metadata/all/batch`
- `<submenu>Remove AI Watermarks</submenu>`, `<image-files/>`/`<directories/>`
  appearance tags, `<command>` uses `%F`
- Installer: awk removes existing `raiw-*` blocks, then inserts new ones before `</actions>`
- Restart: `thunar -q` (or log out/in)

### Nemo (Cinnamon) — .nemo_action
- `[Nemo Action]`, `Name=...`, `Name[pt]=...`, `Name[es]=...`, `Icon=...`
- `Exec="$HELPER" <mode> %F` (external commands: no angle brackets)
- `Selection=notnone`, `Quote=double`
- Image actions: `Extensions=jpg;jpeg;png;webp;bmp;tif;tiff;` (case-insensitive);
  batch: `Extensions=any;`
- Restart: `nemo -q`

### Caja (MATE) — scripts
- Same pattern as Nautilus but `$DATA_DIR/caja/scripts/Remove AI Watermarks/`
- Restart: `caja -q`

### PCManFM (LXDE/LXQt) — DES-EMA
- `Type=Action` `.desktop` files in `$DATA_DIR/file-manager/actions/`
- `[Desktop Entry] Type=Action Profiles=raiw-<mode> Name=... Icon=...`
  + `[X-Action-Profile raiw-<mode>] MimeTypes=... Exec="$HELPER" <mode> %F`
- Image actions: `MimeTypes=image/*;`; batch: `MimeTypes=all/allfiles;inode/directory;`

## Naming contracts (do not change)

| Context           | Pattern                         | Example                 |
| ----------------- | ------------------------------- | ----------------------- |
| Cleaned output    | `<dir>/<stem>_ai_cleaned.<ext>` | `photo_ai_cleaned.jpg`  |
| No-extension file | `<dir>/<name>_ai_cleaned`       | `photo_ai_cleaned`      |
| Identify report   | `<dir>/<stem>_ai_analysis.txt`  | `photo_ai_analysis.txt` |

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
- `notify()` prefers `kdialog --passivepopup <msg> 5` → `zenity --notification`
  → `notify-send`; on missing notifiers it logs and continues.
- `open_file()` prefers `xdg-open` → `kde-open6/5` → `kioclient6/5` → `gio open`
  → `exo-open`; falls back to logging.
- Exit codes: `2` for usage errors (no mode / no files / folder with wrong
  mode), `1` for missing CLI, `0` after processing (even with per-file errors).

## CLI exit-code semantics (helper)

The `remove-ai-watermarks` CLI uses distinct exit codes; the helper maps them
so the user never sees a false "failed":

| CLI rc         | Meaning                                     | Helper treats as                              |
| -------------- | ------------------------------------------- | --------------------------------------------- |
| `0`            | Mark removed / output written               | success                                       |
| `2`            | No mark/signal detected (nothing to remove) | success (logged as "nenhuma marca detectada") |
| `1` (or other) | Hard processing/write failure               | failure (counted in `errors`)                 |

## Installer / uninstaller mechanics

- Per-manager installers are self-contained: they fetch `raiw-helper.sh` via
  curl if missing, write their native integration, `chmod +x` where needed,
  and restart the file manager.
- Per-manager uninstallers remove only their own integration (never the shared
  helper or the CLI).
- All are idempotent and safe to re-run.