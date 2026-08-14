# Remove AI Watermarks — KDE Service Menus

Adds a **right-click context menu** to Dolphin/Konqueror for the
[`remove-ai-watermarks`](https://github.com/wiltodelta/remove-ai-watermarks)
CLI, so you can inspect and clean AI watermarks directly from your file manager.

## Requirements

- **KDE Plasma** (KF5 or KF6) with Dolphin
- **`remove-ai-watermarks`** — this project is a front-end for it and **must be
  installed first**:

  ```bash
  uv tool install --force "remove-ai-watermarks[visible]"
  ```

  See the [remove-ai-watermarks repository](https://github.com/wiltodelta/remove-ai-watermarks)
  for other feature sets (video, invisible removal, etc.).
- `kdialog` (usually preinstalled with Plasma) — used for popup notifications.

## What you get

Right-click an image (or a folder / multiple images) → **Remove AI Watermarks** submenu:

| Selection | Menu items |
|---|---|
| Single image | Identify · Remove visible mark · Remove AI metadata · Remove everything |
| Multiple images (2+) | Batch process (visible) |
| Folder | Batch process (visible) |

- Output files are written **next to the original** as `<name>_ai_cleaned.<ext>`.
- **Identify** writes a full analysis report to `<name>_ai_analysis.txt` and
  opens it in your default text editor.
- Menu labels and helper messages are localized (English default, Portuguese,
  Spanish) based on your system language.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main/install.sh | bash
```

After installing, restart Dolphin once so the menu appears:

```bash
killall dolphin
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main/uninstall.sh | bash
```

Uninstalling removes the context menus and the helper script, but **does not**
remove the `remove-ai-watermarks` tool itself nor any `_ai_cleaned` files you
generated.

## What gets installed

| File | Purpose |
|---|---|
| `~/.local/share/kio/servicemenus/remove-ai-watermarks.desktop` | Context menu for single images |
| `~/.local/share/kio/servicemenus/remove-ai-watermarks-batch.desktop` | Batch action for 2+ selected images |
| `~/.local/share/kio/servicemenus/remove-ai-watermarks-folders.desktop` | Batch action for folders |
| `~/.local/share/remove-ai-watermarks-kde/raiw-helper.sh` | Helper that runs the CLI and names outputs |

Diagnostics are logged to `~/.local/share/remove-ai-watermarks-kde/raiw.log`.

> Note: the installer/uninstaller console output is in Portuguese (the menu
> labels themselves are localized).

## Repository layout

- `install.sh` — self-contained installer (safe to run via `curl | bash`)
- `uninstall.sh` — self-contained uninstaller
- `agents.md` + `.agents/` — documentation for AI agents working on this project