# Dependencies

## Runtime dependencies (end-user system)

| Dependency                                                           | Required | Notes                                                                                                                                                                                                                                                                                 |
| -------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **One supported desktop / file manager**                             | Yes      | Dolphin (KDE), Nautilus (GNOME), Thunar (XFCE), Nemo (Cinnamon), Caja (MATE), PCManFM (LXDE/LXQt)                                                                                                                                                                                     |
| **`remove-ai-watermarks`** CLI                                       | Yes      | The actual watermark engine. **Auto-installed by `install.sh`** (via `install-deps.sh`) when missing from `$PATH` — disable with `--no-deps`. Install: `uv tool install --force --python 3.12 "remove-ai-watermarks[all]"` — see <https://github.com/wiltodelta/remove-ai-watermarks> |
| **`kdialog`** (KDE) / **`zenity`** (GNOME) / **`notify-send`**       | Optional | Popup notifications. When none are available, notifications degrade silently to `raiw.log`                                                                                                                                                                                            |
| **`kbuildsycoca6`** / `kbuildsycoca5`                                | Optional | Refreshes the KDE menu cache at install/uninstall time (Dolphin only). When missing, menus appear only after the next login                                                                                                                                                           |
| **`xdg-open`** / `kde-open6/5` / `kioclient6/5` / `gio` / `exo-open` | Optional | Opens the `_ai_analysis.txt` report in `identify` mode. Falls back in the order listed; if none exist, the report is only saved (logged)                                                                                                                                              |

## Install-time dependencies (only for the installer scripts)

None beyond a POSIX-ish `bash`, standard coreutils (`mkdir`, `cat`, `chmod`,
`rm`, `find`, `date`, `printf`), `awk` (Thunar installer), and `curl` (to
fetch the helper and per-manager scripts). All scripts are fully
self-contained — this is what makes `curl | bash` installation possible.

## Dependency installer (`install-deps.sh`)

`install.sh` calls `install-deps.sh` automatically when the
`remove-ai-watermarks` CLI is not on `$PATH` (disable with `--no-deps`,
force reinstall with `--force-deps`). It:

1. Detects the distro from `/etc/os-release` (`ID` + `ID_LIKE`).
2. Ensures `uv` — tries the distro package manager first
   (`pacman -S uv`, `apt-get install uv`, `dnf install uv`,
   `zypper install uv`), falling back to the official installer
   (`curl -LsSf https://astral.sh/uv/install.sh | sh`, user-level, no sudo).
3. Ensures a compatible Python (`uv python install 3.12`).
4. Installs the CLI: `uv tool install --force --python 3.12 "remove-ai-watermarks[all]"`.
   The extra is configurable via `RAIW_EXTRA` (default `all`).
5. Verifies `remove-ai-watermarks` is on `$PATH`, warning about `~/.local/bin`.

`uninstall-deps.sh` removes the CLI via `uv tool uninstall remove-ai-watermarks`
(it never removes `uv` or Python). `uninstall.sh` calls it with `--deps` or
after an interactive prompt (default: no).

## Version compatibility

- The helper probes for `kde-open6` → `kde-open5` → `kde-open` and
  `kioclient6` → `kioclient5` → `kioclient`, and `kbuildsycoca6` →
  `kbuildsycoca5`, so both Plasma 6 (KF6) and Plasma 5 (KF5) are supported.
- The CLI is invoked as `remove-ai-watermarks <mode> <file> -o <output>` for
  cleaning modes and `remove-ai-watermarks identify <file>` for analysis.
  Mode names are stable across CLI versions: `visible`, `metadata`, `all`,
  `identify`.