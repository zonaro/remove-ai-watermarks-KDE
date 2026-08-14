# agents.md — Guide for AI agents working on this project

This file is a quick orientation for AI agents (or humans) modifying this
repository. Detailed documentation lives in [`.agents/`](.agents/).

## What this project is

Right-click context menus that expose the
[`remove-ai-watermarks`](https://github.com/wiltodelta/remove-ai-watermarks)
CLI in multiple file managers (Dolphin, Nautilus, Thunar, Nemo, Caja, PCManFM).

- `install.sh` — main installer (dispatcher). Detects the desktop environment
  and installed file managers, installs the shared helper, then calls each
  per-manager installer via `curl ... | bash`.
- `uninstall.sh` — main uninstaller (dispatcher). Calls every per-manager
  uninstaller, then removes the shared app directory.
- `install-<fm>.sh` / `uninstall-<fm>.sh` — one pair per file manager.
- `raiw-helper.sh` — shared helper executed by the menus (single source of
  truth; each installer fetches it via curl if missing).

## Architecture in one paragraph

`install.sh` detects the DE (`$XDG_CURRENT_DESKTOP`) and installed file
managers (`command -v dolphin nautilus thunar nemo caja pcmanfm...`), installs
the shared helper, and dispatches to per-manager installers via
`curl -fsSL <raw-url>/install-<fm>.sh | bash`. Each per-manager installer
writes its native integration (ServiceMenus, Nautilus/Caja scripts, Thunar
`uca.xml`, Nemo `.nemo_action`, PCManFM DES-EMA actions). The helper resolves
the CLI path, localizes its messages from `$LANG` (pt/es/en), processes each
target (single file, or level-1 images of a folder in `batch` mode), names
outputs `<name>_ai_cleaned.<ext>` next to the original, and reports via
`kdialog`/`zenity`/`notify-send` (falling back to `raiw.log`). `identify` mode
accumulates a report into `<name>_ai_analysis.txt` and opens it with the system
default opener.

## Hard constraints (do not break)

1. **Scripts must stay self-contained.** They are installed via
   `curl -fsSL <raw-url> | bash` — never reference the repo path, never depend
   on sibling files, never use `$0`/`BASH_SOURCE` for locating resources.
   (The helper's `dirname "$0"` is fine: it resolves to the installed path.)
2. **`set -euo pipefail`** in the top-level scripts and per-manager scripts;
   the helper uses `set -u`.
3. **Output naming is contractual**: `<name>_ai_cleaned.<ext>` for cleaning,
   `<name>_ai_analysis.txt` for identify. `batch_dir` must keep skipping
   `*_ai_cleaned.*` files.
4. **Localization pattern**: every user-facing string in the helper is a
   `L_*` variable set by the `case "${LANG:-}"` block; every menu entry carries
   `Name[pt]`/`Name[es]` variants. New strings must follow both.
5. **Native formats must stay valid** (see `.agents/architecture.md` for the
   exact fields per file manager).
6. **`chmod +x`** on the helper and all `.desktop`/script files — KDE refuses
   to run ServiceMenus without the executable bit, and Nautilus/Caja scripts
   must be executable too.
7. **Notifications are optional at runtime**: every notify call must degrade to
   the log file (`raiw.log`) when no notifier is available.

## Testing checklist

```bash
bash -n install.sh uninstall.sh raiw-helper.sh install-*.sh uninstall-*.sh  # syntax
RAIW_BASE_URL="file://$PWD" ./install.sh --all   # install all (local test)
ls ~/.local/share/kio/servicemenus/              # dolphin: 3 .desktop files
ls ~/.local/share/nautilus/scripts/Remove\ AI\ Watermarks/
ls ~/.config/Thunar/uca.xml
ls ~/.local/share/nemo/actions/
ls ~/.local/share/caja/scripts/Remove\ AI\ Watermarks/
ls ~/.local/share/file-manager/actions/
ls ~/.local/share/remove-ai-watermarks-kde/      # helper + raiw.log
RAIW_BASE_URL="file://$PWD" ./uninstall.sh       # verify clean removal
```

The helper can be exercised directly:
`~/.local/share/remove-ai-watermarks-kde/raiw-helper.sh identify <image>`
— check `raiw.log` and the generated TXT.

## Commit conventions

Concise, descriptive, no prefix convention (repo style: plain imperative
messages, e.g. `identify: salva análise em <nome>_ai_analysis.txt e abre no
editor padrão`). Stage only intended files.

## More docs

- `.agents/dependencies.md` — runtime and install-time dependencies
- `.agents/architecture.md` — files, data flow, naming, per-manager formats
- `.agents/localization.md` — languages, detection, how to add one
- `.agents/development.md` — editing, testing, releasing