# Localization

## Supported languages

| Code | Language | Where |
|---|---|---|
| `pt` | Portuguese (default for the installer's console output) | Helper messages + `Name[pt]` in all `.desktop` files |
| `es` | Spanish | Helper messages + `Name[es]` in all `.desktop` files |
| `en` | English (fallback) | Helper messages + base `Name=` in all `.desktop` files |

## Detection mechanism

The helper detects the system language from the `LANG` environment variable:

```bash
case "${LANG:-}" in
    pt*) ... ;;   # Portuguese
    es*) ... ;;   # Spanish
    *)    ... ;;  # English fallback
esac
```

The `.desktop` files use the standard KDE mechanism: `Name=` is the default,
`Name[pt]=` / `Name[es]=` are locale variants chosen by KDE itself.

## String inventory

### Helper (`raiw-helper.sh`) — `L_*` variables

| Variable | Purpose |
|---|---|
| `L_ERR` | Error popup title |
| `L_MODE` | "Mode not specified" |
| `L_NOTFOUND` | CLI not found in PATH |
| `L_NOFILE` | No file selected |
| `L_FOLDER` | Folder selected with a non-batch mode |
| `L_MISSING` | Target file not found (`%s`) |
| `L_DONE` | Success summary (`%s` = processed count) |
| `L_FAIL` | Failure summary (`%s` = errors, `%s` = processed) |
| `L_IDENT_FAIL` | Identify failed for file (`%s`) |
| `L_IDENT_WORKING` | "Analyzing %s... please wait" popup |
| `L_TXT_HEADER` | Report header line |
| `L_TXT_FILE` | Report file marker (`>>> File:`) |

### `.desktop` files — action names

Each action has `Name`, `Name[pt]`, `Name[es]`:

| Action | en | pt | es |
|---|---|---|---|
| `identify` | Identify (identify) | Identificar (identify) | Identificar (identify) |
| `visible` | Remove visible mark (visible) | Remover marca visível (visible) | Eliminar marca visible (visible) |
| `metadata` | Remove AI metadata (metadata) | Remover metadados AI (metadata) | Eliminar metadatos IA (metadata) |
| `all` | Remove everything (all) | Remover tudo (all) | Eliminar todo (all) |
| `batch` | Batch process (visible) | Processar em lote (visible) | Procesar por lotes (visible) |

Plus the submenu/file names: `Remove AI Watermarks` (+ `(lote)` / `(pastas)` /
`(carpetas)` variants).

## How to add a new language

1. Add a new `case` branch in the helper's localization block (e.g. `fr*`).
2. Add `Name[fr]=` to every action in all three `.desktop` files.
3. Keep the English branch as the `*)` fallback.
4. Never hardcode a user-facing string outside the localization block or
   outside `Name[xx]=` entries.

## Installer console output

`install.sh` and `uninstall.sh` print their progress in Portuguese (they are
developer/installer-facing, not user-facing menus). This is intentional; the
README notes it for English-speaking users.