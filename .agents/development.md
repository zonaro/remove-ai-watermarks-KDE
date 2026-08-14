# Development

## Editing workflow

1. Edit `install.sh` (installer + embedded helper + `.desktop` templates) or
   `uninstall.sh`. There is no build step — the files are the product.
2. Syntax-check everything:
   ```bash
   bash -n install.sh uninstall.sh
   ```
3. Install and verify on a real KDE session (see checklist below).
4. Commit with a concise descriptive message and push.

## Testing checklist

```bash
# 1. Syntax
bash -n install.sh uninstall.sh

# 2. Install (idempotent — safe to re-run)
./install.sh

# 3. Reload menus
killall dolphin

# 4. Verify installed files
ls -l ~/.local/share/kio/servicemenus/remove-ai-watermarks*.desktop
ls -l ~/.local/share/remove-ai-watermarks-kde/raiw-helper.sh

# 5. Exercise the helper directly (bypasses Dolphin)
~/.local/share/remove-ai-watermarks-kde/raiw-helper.sh identify ~/test.png
#   → expect ~/test_ai_analysis.txt created and opened in the default editor
~/.local/share/remove-ai-watermarks-kde/raiw-helper.sh visible ~/test.png
#   → expect ~/test_ai_cleaned.png
#   → check ~/.local/share/remove-ai-watermarks-kde/raiw.log for diagnostics

# 6. Uninstall and verify clean removal
./uninstall.sh
ls ~/.local/share/kio/servicemenus/remove-ai-watermarks*   # → nothing
ls ~/.local/share/remove-ai-watermarks-kde/                # → nothing
```

## Constraints when editing (summary)

- **Self-contained scripts**: `install.sh`/`uninstall.sh` are fetched from raw
  GitHub and piped to `bash`. Never reference repo paths, sibling files, or
  `$0`/`BASH_SOURCE` to locate resources. The helper's `dirname "$0"` is safe
  because it resolves to the installed location at runtime.
- **Heredoc discipline**: the helper is embedded with a **quoted** heredoc
  (`<<'HELPER_EOF'`) so `$`/backticks inside it are literal; the `.desktop`
  files use **unquoted** heredocs because they must expand `$HELPER`. If you
  add `$`-content to the helper, keep it inside the quoted heredoc.
- **Naming contracts**: `<name>_ai_cleaned.<ext>` and `<name>_ai_analysis.txt`
  are user-visible guarantees; `batch_dir` must keep skipping `*_ai_cleaned.*`.
- **Localization**: every new user-facing string needs the `L_*` variable in
  all three language branches (pt/es/en) and `Name[pt]`/`Name[es]` in the
  `.desktop` files.
- **kdialog optional**: notifications must degrade to `raiw.log`.
- **Executable bits**: helper + `.desktop` files must stay `chmod +x`.

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
```

## Known behaviors / gotchas

- `xdg-open` from a Dolphin-launched context can silently fail to surface a
  window even when it returns 0; the helper backgrounds it and logs. If the
  report doesn't open, it is always still saved next to the image.
- `kbuildsycoca` only refreshes the menu cache; Dolphin must be restarted
  (`killall dolphin`) for menus to appear/disappear.
- The helper runs with `set -u` only — per-file failures are counted and
  reported, never fatal.
- `identify` on a folder is rejected with a localized popup (batch is the
  folder mode).