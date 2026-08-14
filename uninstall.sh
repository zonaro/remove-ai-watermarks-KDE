#!/usr/bin/env bash
# =============================================================================
# Desinstalador principal "Remove AI Watermarks" — multi-desktop.
#
# Este script:
#   1. Chama TODOS os desinstaladores por gerenciador (idempotentes — só
#      removem o que existe)
#   2. Remove o diretório compartilhado (~/.local/share/remove-ai-watermarks-kde/)
#   3. Opcionalmente remove o CLI remove-ai-watermarks (--deps ou confirmação)
#
# NÃO remove o remove-ai-watermarks nem os arquivos _ai_cleaned gerados,
# a menos que --deps seja informado.
#
# Uso:
#   curl -fsSL <raw>/uninstall.sh | bash
#   curl -fsSL <raw>/uninstall.sh | bash -s -- --deps   # remove também o CLI
#
# Para testes locais, defina RAIW_BASE_URL (ex: file:///caminho/do/repo).
# =============================================================================
set -euo pipefail

BASE_URL="${RAIW_BASE_URL:-https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-contextmenu/main}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
APP_DIR="$DATA_DIR/remove-ai-watermarks-kde"

DEPS=0
[ "${1:-}" = "--deps" ] && DEPS=1

# Pergunta se o usuário quer remover também o CLI (lê do terminal real,
# mesmo quando o script é executado via curl | bash)
ask_remove_deps() {
    if [ -r /dev/tty ] && [ -w /dev/tty ]; then
        printf "Remover também o CLI remove-ai-watermarks? [s/N] " > /dev/tty
        local ans=""
        read -r ans < /dev/tty || true
        case "$ans" in
            s|S|sim|SIM|y|Y|yes|YES) return 0 ;;
            *) return 1 ;;
        esac
    fi
    return 1
}

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

# ---------------------------------------------------------------------------
# Dependência (opcional): remove-ai-watermarks CLI
# ---------------------------------------------------------------------------
if [ "$DEPS" -eq 1 ] || ask_remove_deps; then
    echo
    echo "============================================================"
    echo " Dependência: remove-ai-watermarks"
    echo "============================================================"
    curl -fsSL "$BASE_URL/uninstall-deps.sh" | bash
else
    echo
    echo "==> Dica: para remover também o CLI remove-ai-watermarks,"
    echo "    rode: curl -fsSL $BASE_URL/uninstall.sh | bash -s -- --deps"
fi

echo
echo "============================================================"
echo " Desinstalação concluída!"
echo "============================================================"
echo " Reinicie os gerenciadores para o menu desaparecer."
echo "============================================================"