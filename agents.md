# agents.md — Guide for AI agents working on this project

This file is a quick orientation for AI agents (or humans) modifying this
repository. Detailed documentation lives in [`.agents/`](.agents/).

## What this project is

KDE ServiceMenus that expose the
[`remove-ai-watermarks`](https://github.com/wiltodelta/remove-ai-watermarks)
CLI as a right-click context menu in Dolphin/Konqueror.

- `install.sh` — self-contained installer. Writes the helper script and three
  `.desktop` ServiceMenus, then refreshes the KDE cache.
- `uninstall.sh` — self-contained uninstaller. Removes everything the installer
  created (never the CLI tool or generated `_ai_cleaned` files).

## Architecture in one paragraph

KDE executes `raiw-helper.sh <mode> <files...>` from a ServiceMenu. The helper
resolves the CLI path, localizes its messages from `$LANG` (pt/es/en), processes
each target (single file, or level-1 images of a folder in `batch` mode), names
outputs `<name>_ai_cleaned.<ext>` next to the original, and reports via
`kdialog --passivepopup`. `identify` mode accumulates a report into
`<name>_ai_analysis.txt` and opens it with the system default opener.

## Hard constraints (do not break)

1. **Scripts must stay self-contained.** They are installed via
   `curl -fsSL <raw-url> | bash` — never reference the repo path, never depend
   on sibling files, never use `$0`/`BASH_SOURCE` for locating resources.
   (The helper's `dirname "$0"` is fine: it resolves to the installed path.)
2. **`set -euo pipefail`** in both top-level scripts; the helper uses `set -u`.
3. **Output naming is contractual**: `<name>_ai_cleaned.<ext>` for cleaning,
   `<name>_ai_analysis.txt` for identify. `batch_dir` must keep skipping
   `*_ai_cleaned.*` files.
4. **Localization pattern**: every user-facing string in the helper is a
   `L_*` variable set by the `case "${LANG:-}"` block; every `.desktop` action
   carries `Name[pt]`/`Name[es]` variants. New strings must follow both.
5. **`.desktop` files must stay valid KDE ServiceMenu format** (see
   `.agents/architecture.md` for the exact fields used).
6. **`chmod +x`** on the helper and all `.desktop` files — KDE refuses to run
   ServiceMenus without the executable bit.
7. **kdialog is optional at runtime**: every notify call must degrade to the
   log file (`raiw.log`) when kdialog is missing.

## Testing checklist

```bash
bash -n install.sh uninstall.sh          # syntax check
./install.sh                             # install (idempotent)
killall dolphin                          # reload menus
ls ~/.local/share/kio/servicemenus/      # 3 .desktop files present
ls ~/.local/share/remove-ai-watermarks-kde/  # helper + raiw.log
./uninstall.sh                           # verify clean removal
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
- `.agents/architecture.md` — files, data flow, naming, batch logic
- `.agents/localization.md` — languages, detection, how to add one
- `.agents/development.md` — editing, testing, releasing