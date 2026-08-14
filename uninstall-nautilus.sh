#!/usr/bin/env bash
# =============================================================================
# Desinstala o menu de contexto "Remove AI Watermarks" do Nautilus (GNOME Files).
#
# Remove:
#   1. A subpasta de scripts ~/.local/share/nautilus/scripts/Remove AI Watermarks/
#   2. Reinicia o Nautilus (nautilus -q)
#
# NÃO remove o script auxiliar compartilhado (o uninstall.sh principal cuida
# disso), nem o remove-ai-watermarks, nem os arquivos _ai_cleaned gerados.
# =============================================================================
set -euo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
SCRIPT_DIR="$DATA_DIR/nautilus/scripts/Remove AI Watermarks"

echo "==> Removendo scripts do Nautilus..."
if [ -d "$SCRIPT_DIR" ]; then
    rm -rf "$SCRIPT_DIR"
    echo "    removido: $SCRIPT_DIR"
else
    echo "    (nada a remover)"
fi

if command -v nautilus >/dev/null 2>&1; then
    echo "==> Reiniciando o Nautilus (nautilus -q)..."
    nautilus -q >/dev/null 2>&1 || true
fi

echo
echo "============================================================"
echo " Nautilus (GNOME Files): desinstalação concluída!"
echo "============================================================"