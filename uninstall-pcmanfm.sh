#!/usr/bin/env bash
# =============================================================================
# Desinstala o menu de contexto "Remove AI Watermarks" do PCManFM (LXDE/LXQt).
#
# Remove:
#   1. Os arquivos .desktop DES-EMA de ~/.local/share/file-manager/actions/
#
# NÃO remove o script auxiliar compartilhado (o uninstall.sh principal cuida
# disso), nem o remove-ai-watermarks, nem os arquivos _ai_cleaned gerados.
# =============================================================================
set -euo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
ACTIONS_DIR="$DATA_DIR/file-manager/actions"

ACTION_FILES=(
    "$ACTIONS_DIR/remove-ai-watermarks-identify.desktop"
    "$ACTIONS_DIR/remove-ai-watermarks-visible.desktop"
    "$ACTIONS_DIR/remove-ai-watermarks-metadata.desktop"
    "$ACTIONS_DIR/remove-ai-watermarks-all.desktop"
    "$ACTIONS_DIR/remove-ai-watermarks-batch.desktop"
)

echo "==> Removendo ações do PCManFM..."
removed=0
for f in "${ACTION_FILES[@]}"; do
    if [ -f "$f" ]; then
        rm -f "$f"
        echo "    removido: $f"
        removed=$((removed + 1))
    fi
done
[ "$removed" -eq 0 ] && echo "    (nenhuma ação encontrada)"

echo
echo "============================================================"
echo " PCManFM (LXDE/LXQt): desinstalação concluída!"
echo "============================================================"
echo " Reinicie o PCManFM para o menu desaparecer."
echo "============================================================"