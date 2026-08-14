#!/usr/bin/env bash
# =============================================================================
# Desinstala o menu de contexto "Remove AI Watermarks" do Nemo (Cinnamon).
#
# Remove:
#   1. Os arquivos .nemo_action de ~/.local/share/nemo/actions/
#   2. Reinicia o Nemo (nemo -q)
#
# NÃO remove o script auxiliar compartilhado (o uninstall.sh principal cuida
# disso), nem o remove-ai-watermarks, nem os arquivos _ai_cleaned gerados.
# =============================================================================
set -euo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
ACTIONS_DIR="$DATA_DIR/nemo/actions"

ACTION_FILES=(
    "$ACTIONS_DIR/remove-ai-watermarks-identify.nemo_action"
    "$ACTIONS_DIR/remove-ai-watermarks-visible.nemo_action"
    "$ACTIONS_DIR/remove-ai-watermarks-metadata.nemo_action"
    "$ACTIONS_DIR/remove-ai-watermarks-all.nemo_action"
    "$ACTIONS_DIR/remove-ai-watermarks-batch.nemo_action"
)

echo "==> Removendo ações do Nemo..."
removed=0
for f in "${ACTION_FILES[@]}"; do
    if [ -f "$f" ]; then
        rm -f "$f"
        echo "    removido: $f"
        removed=$((removed + 1))
    fi
done
[ "$removed" -eq 0 ] && echo "    (nenhuma ação encontrada)"

if command -v nemo >/dev/null 2>&1; then
    echo "==> Reiniciando o Nemo (nemo -q)..."
    nemo -q >/dev/null 2>&1 || true
fi

echo
echo "============================================================"
echo " Nemo (Cinnamon): desinstalação concluída!"
echo "============================================================"