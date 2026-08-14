# Dependencies

## Runtime dependencies (end-user system)

| Dependency | Required | Notes |
|---|---|---|
| **KDE Plasma** (KF5 or KF6) | Yes | Provides Dolphin/Konqueror and the ServiceMenu infrastructure (`kio/servicemenus`) |
| **`remove-ai-watermarks`** CLI | Yes | The actual watermark engine. **Must be installed before use** — the menus are installed regardless, but actions fail until the CLI is on `$PATH`. Install: `uv tool install --force "remove-ai-watermarks[visible]"` — see <https://github.com/wiltodelta/remove-ai-watermarks> |
| **`kdialog`** | Optional | Popup notifications (`--passivepopup`). When missing, notifications degrade silently to `raiw.log` |
| **`kbuildsycoca6`** / `kbuildsycoca5` | Optional | Refreshes the KDE menu cache at install/uninstall time. When missing, menus appear only after the next login |
| **`xdg-open`** / `kde-open6/5` / `kioclient6/5` | Optional | Opens the `_ai_analysis.txt` report in `identify` mode. Falls back in the order listed; if none exist, the report is only saved (logged) |

## Install-time dependencies (only for the installer scripts)

None beyond a POSIX-ish `bash` and standard coreutils (`mkdir`, `cat`,
`chmod`, `rm`, `find`, `date`, `printf`). Both `install.sh` and `uninstall.sh`
are fully self-contained — this is what makes `curl | bash` installation
possible.

## Version compatibility

- The helper probes for `kde-open6` → `kde-open5` → `kde-open` and
  `kioclient6` → `kioclient5` → `kioclient`, and `kbuildsycoca6` →
  `kbuildsycoca5`, so both Plasma 6 (KF6) and Plasma 5 (KF5) are supported.
- The CLI is invoked as `remove-ai-watermarks <mode> <file> -o <output>` for
  cleaning modes and `remove-ai-watermarks identify <file>` for analysis.
  Mode names are stable across CLI versions: `visible`, `metadata`, `all`,
  `identify`.