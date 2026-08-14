# Remove AI Watermarks — Context Menus for File Managers

Adds a **right-click context menu** to your file manager for the
[`remove-ai-watermarks`](https://github.com/wiltodelta/remove-ai-watermarks)
CLI, so you can inspect and clean AI watermarks directly from your file manager.

Works on **multiple desktop environments** and file managers:

| Desktop | File manager | Mechanism |
|---|---|---|
| KDE Plasma | Dolphin / Konqueror | KDE ServiceMenus |
| GNOME | Nautilus | Nautilus scripts |
| XFCE | Thunar | Thunar custom actions (`uca.xml`) |
| Cinnamon | Nemo | Nemo actions (`.nemo_action`) |
| MATE | Caja | Caja scripts |
| LXDE / LXQt | PCManFM | DES-EMA actions |

The installer detects your desktop environment and the file managers
installed, and installs the menu in **all compatible managers** found.

## Requirements

- One of the supported desktop environments / file managers above
- **`remove-ai-watermarks`** — this project is a front-end for it and **must be
  installed first**:

  ```bash
  uv tool install --force "remove-ai-watermarks[visible]"
  ```

  See the [remove-ai-watermarks repository](https://github.com/wiltodelta/remove-ai-watermarks)
  for other feature sets (video, invisible removal, etc.).
- `kdialog` (KDE), `zenity` (GNOME) or `notify-send` — used for popup
  notifications. When none are available, notifications degrade to a log file.

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
curl -fsSL https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-contextmenu/main/install.sh | bash
```

The installer detects your desktop environment and installed file managers and
installs the menu in all of them. To force installation in every supported
manager:

```bash
curl -fsSL https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-contextmenu/main/install.sh | bash -s -- --all
```

After installing, restart your file manager once so the menu appears:

```bash
killall dolphin      # KDE
nautilus -q          # GNOME
thunar -q            # XFCE (or log out/in)
nemo -q              # Cinnamon
caja -q              # MATE
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-contextmenu/main/uninstall.sh | bash
```

Uninstalling removes the context menus and the helper script, but **does not**
remove the `remove-ai-watermarks` tool itself nor any `_ai_cleaned` files you
generated.

## What gets installed

| File manager | Files |
|---|---|
| Dolphin (KDE) | `~/.local/share/kio/servicemenus/remove-ai-watermarks*.desktop` |
| Nautilus (GNOME) | `~/.local/share/nautilus/scripts/Remove AI Watermarks/*` |
| Thunar (XFCE) | `~/.config/Thunar/uca.xml` (adds `raiw-*` actions) |
| Nemo (Cinnamon) | `~/.local/share/nemo/actions/remove-ai-watermarks*.nemo_action` |
| Caja (MATE) | `~/.local/share/caja/scripts/Remove AI Watermarks/*` |
| PCManFM (LXDE/LXQt) | `~/.local/share/file-manager/actions/remove-ai-watermarks*.desktop` |
| Shared | `~/.local/share/remove-ai-watermarks-kde/raiw-helper.sh` |

Diagnostics are logged to `~/.local/share/remove-ai-watermarks-kde/raiw.log`.

> Note: the installer/uninstaller console output is in Portuguese (the menu
> labels themselves are localized).

## Repository layout

- `install.sh` — main installer: detects environment, dispatches per manager
- `uninstall.sh` — main uninstaller: removes all integrations
- `install-<fm>.sh` / `uninstall-<fm>.sh` — per-file-manager installers/uninstallers
- `raiw-helper.sh` — shared helper executed by the menus
- `agents.md` + `.agents/` — documentation for AI agents working on this project