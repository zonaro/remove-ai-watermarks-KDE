#!/usr/bin/env bash
# =============================================================================
# Desinstala o menu de contexto "Remove AI Watermarks" do KDE.
#
# Remove:
#   1. Os ServiceMenus (.desktop) de ~/.local/share/kio/servicemenus/
#   2. O script auxiliar em ~/.local/share/remove-ai-watermarks-kde/
#   3. Atualiza o cache do KDE (kbuildsycoca6)
#
# NÃO remove o remove-ai-watermarks nem os arquivos _ai_cleaned gerados.
# =============================================================================
set -euo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
MENU_DIR="$DATA_DIR/kio/servicemenus"
APP_DIR="$DATA_DIR/remove-ai-watermarks-kde"

DESKTOP_FILES=(
    "$MENU_DIR/remove-ai-watermarks.desktop"
    "$MENU_DIR/remove-ai-watermarks-batch.desktop"
    "$MENU_DIR/remove-ai-watermarks-folders.desktop"
)

echo "==> Removendo ServiceMenus..."
removed=0
for f in "${DESKTOP_FILES[@]}"; do
    if [ -f "$f" ]; then
        rm -f "$f"
        echo "    removido: $f"
        removed=$((removed + 1))
    fi
done
[ "$removed" -eq 0 ] && echo "    (nenhum ServiceMenu encontrado)"

echo "==> Removendo o script auxiliar..."
if [ -d "$APP_DIR" ]; then
    rm -rf "$APP_DIR"
    echo "    removido: $APP_DIR"
else
    echo "    (nada a remover)"
fi

echo "==> Atualizando o cache do KDE (kbuildsycoca)..."
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 >/dev/null 2>&1 || true
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
    kbuildsycoca5 >/dev/null 2>&1 || true
else
    echo "    AVISO: kbuildsycoca não encontrado."
fi

echo
echo "============================================================"
echo " Desinstalação concluída!"
echo "============================================================"
echo " Reinicie o Dolphin (killall dolphin) para o menu desaparecer."
echo "============================================================"