#!/usr/bin/env bash
# =============================================================================
# Desinstala o menu de contexto "Remove AI Watermarks" do Caja (MATE).
#
# Remove:
#   1. A subpasta de scripts ~/.local/share/caja/scripts/Remove AI Watermarks/
#   2. Reinicia o Caja (caja -q)
#
# NÃO remove o script auxiliar compartilhado (o uninstall.sh principal cuida
# disso), nem o remove-ai-watermarks, nem os arquivos _ai_cleaned gerados.
# =============================================================================
set -euo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
SCRIPT_DIR="$DATA_DIR/caja/scripts/Remove AI Watermarks"

echo "==> Removendo scripts do Caja..."
if [ -d "$SCRIPT_DIR" ]; then
    rm -rf "$SCRIPT_DIR"
    echo "    removido: $SCRIPT_DIR"
else
    echo "    (nada a remover)"
fi

if command -v caja >/dev/null 2>&1; then
    echo "==> Reiniciando o Caja (caja -q)..."
    caja -q >/dev/null 2>&1 || true
fi

echo
echo "============================================================"
echo " Caja (MATE): desinstalação concluída!"
echo "============================================================"