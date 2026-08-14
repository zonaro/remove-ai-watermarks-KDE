# Development

## Editing workflow

1. Edit the shared helper (`raiw-helper.sh`), a per-manager installer
   (`install-<fm>.sh` / `uninstall-<fm>.sh`), or the dispatchers
   (`install.sh` / `uninstall.sh`). There is no build step — the files are
   the product.
2. Syntax-check everything:
   ```bash
   bash -n install.sh uninstall.sh raiw-helper.sh install-*.sh uninstall-*.sh
   ```
3. Install and verify locally (see checklist below).
4. Commit with a concise descriptive message and push.

## Testing checklist

```bash
# 1. Syntax
bash -n install.sh uninstall.sh raiw-helper.sh install-*.sh uninstall-*.sh

# 2. Install all managers locally (RAIW_BASE_URL points at the repo)
RAIW_BASE_URL="file://$PWD" ./install.sh --all

# 3. Verify installed files
ls -l ~/.local/share/kio/servicemenus/remove-ai-watermarks*.desktop
ls -l ~/.local/share/nautilus/scripts/Remove\ AI\ Watermarks/
ls -l ~/.config/Thunar/uca.xml
ls -l ~/.local/share/nemo/actions/
ls -l ~/.local/share/caja/scripts/Remove\ AI\ Watermarks/
ls -l ~/.local/share/file-manager/actions/
ls -l ~/.local/share/remove-ai-watermarks-kde/raiw-helper.sh

# 4. Exercise the helper directly (bypasses the file manager)
~/.local/share/remove-ai-watermarks-kde/raiw-helper.sh identify ~/test.png
#   → expect ~/test_ai_analysis.txt created and opened in the default editor
~/.local/share/remove-ai-watermarks-kde/raiw-helper.sh visible ~/test.png
#   → expect ~/test_ai_cleaned.png
#   → check ~/.local/share/remove-ai-watermarks-kde/raiw.log for diagnostics

# 5. Uninstall and verify clean removal
RAIW_BASE_URL="file://$PWD" ./uninstall.sh
ls ~/.local/share/kio/servicemenus/remove-ai-watermarks*   # → nothing
ls ~/.local/share/nautilus/scripts/Remove\ AI\ Watermarks/ # → nothing
ls ~/.local/share/remove-ai-watermarks-kde/                # → nothing
```

## Constraints when editing (summary)

- **Self-contained scripts**: all scripts are fetched from raw GitHub and
  piped to `bash`. Never reference repo paths, sibling files, or
  `$0`/`BASH_SOURCE` to locate resources. The helper's `dirname "$0"` is safe
  because it resolves to the installed location at runtime.
- **Dispatcher discipline**: `install.sh`/`uninstall.sh` only detect and
  dispatch — all integration logic lives in the per-manager scripts. Keep it
  that way.
- **Naming contracts**: `<name>_ai_cleaned.<ext>` and `<name>_ai_analysis.txt`
  are user-visible guarantees; `batch_dir` must keep skipping `*_ai_cleaned.*`.
- **Localization**: every new user-facing string needs the `L_*` variable in
  all three language branches (pt/es/en) and `Name[pt]`/`Name[es]` in the
  menu files.
- **Notifications optional**: notifications must degrade to `raiw.log`.
- **Executable bits**: helper + `.desktop`/script files must stay `chmod +x`.

## Release / install-from-URL

The documented install path is:

```bash
curl -fsSL https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main/install.sh | bash
```

Because the raw URL points at the `main` branch, **pushing to `main` is the
release step**. Verify the raw URLs resolve after pushing:

```bash
curl -fsSL https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main/install.sh | bash -n
curl -fsSL https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main/uninstall.sh | bash -n
curl -fsSL https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main/raiw-helper.sh | bash -n
curl -fsSL https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main/install-dolphin.sh | bash -n
# ... and so on for every install-*/uninstall-* script
```

## Known behaviors / gotchas

- `xdg-open` from a file-manager-launched context can silently fail to surface
  a window even when it returns 0; the helper backgrounds it and logs. If the
  report doesn't open, it is always still saved next to the image.
- `kbuildsycoca` only refreshes the KDE menu cache; Dolphin must be restarted
  (`killall dolphin`) for menus to appear/disappear. Nautilus/Caja/Nemo need
  `nautilus -q` / `caja -q` / `nemo -q`; Thunar needs `thunar -q` or a
  re-login.
- The helper runs with `set -u` only — per-file failures are counted and
  reported, never fatal.
- `identify` on a folder is rejected with a localized popup (batch is the
  folder mode).
- The Thunar installer uses `awk` to surgically remove/replace `raiw-*`
  blocks in `uca.xml`; keep the state machine intact when editing.