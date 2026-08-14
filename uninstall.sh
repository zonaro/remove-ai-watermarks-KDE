#!/usr/bin/env bash
# =============================================================================
# Desinstalador principal "Remove AI Watermarks" — multi-desktop.
#
# Este script:
#   1. Chama TODOS os desinstaladores por gerenciador (idempotentes — só
#      removem o que existe)
#   2. Remove o diretório compartilhado (~/.local/share/remove-ai-watermarks-kde/)
#
# NÃO remove o remove-ai-watermarks nem os arquivos _ai_cleaned gerados.
#
# Uso:
#   curl -fsSL <raw>/uninstall.sh | bash
#
# Para testes locais, defina RAIW_BASE_URL (ex: file:///caminho/do/repo).
# =============================================================================
set -euo pipefail

BASE_URL="${RAIW_BASE_URL:-https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
APP_DIR="$DATA_DIR/remove-ai-watermarks-kde"

echo "==> Removendo integrações dos gerenciadores de arquivos..."

for fm in dolphin nautilus thunar nemo caja pcmanfm; do
    echo
    echo "============================================================"
    echo " Desinstalando de: $fm"
    echo "============================================================"
    curl -fsSL "$BASE_URL/uninstall-$fm.sh" | bash || true
done

echo
echo "==> Removendo o diretório compartilhado..."
if [ -d "$APP_DIR" ]; then
    rm -rf "$APP_DIR"
    echo "    removido: $APP_DIR"
else
    echo "    (nada a remover)"
fi

echo
echo "============================================================"
echo " Desinstalação concluída!"
echo "============================================================"
echo " Reinicie os gerenciadores para o menu desaparecer."
echo "============================================================"