#!/usr/bin/env bash
# =============================================================================
# Instalador principal "Remove AI Watermarks" — multi-desktop.
#
# Este script é o ponto de entrada. Ele:
#   1. Detecta o ambiente desktop (KDE, GNOME, XFCE, Cinnamon, MATE, LXDE/LXQt)
#   2. Detecta os gerenciadores de arquivos instalados (dolphin, nautilus,
#      thunar, nemo, caja, pcmanfm) — instala em TODOS os encontrados
#   3. Instala o script auxiliar compartilhado (raiw-helper.sh)
#   4. Chama via curl o instalador específico de cada gerenciador
#
# Uso:
#   curl -fsSL <raw>/install.sh | bash
#   curl -fsSL <raw>/install.sh | bash -s -- --all   # força todos os FMs
#
# Para testes locais, defina RAIW_BASE_URL (ex: file:///caminho/do/repo).
# =============================================================================
set -euo pipefail

BASE_URL="${RAIW_BASE_URL:-https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
APP_DIR="$DATA_DIR/remove-ai-watermarks-kde"
HELPER="$APP_DIR/raiw-helper.sh"

# ---------------------------------------------------------------------------
# Detecção de ambiente e gerenciadores
# ---------------------------------------------------------------------------
DE="${XDG_CURRENT_DESKTOP:-}"
echo "==> Ambiente detectado: ${DE:-desconhecido}"

# Mapeia um gerenciador para o nome do script de instalação
fm_script() {
    case "$1" in
        dolphin)     echo "dolphin" ;;
        nautilus)    echo "nautilus" ;;
        thunar)      echo "thunar" ;;
        nemo)        echo "nemo" ;;
        caja)        echo "caja" ;;
        pcmanfm|pcmanfm-qt) echo "pcmanfm" ;;
        *)           return 1 ;;
    esac
}

# Fallback: ambiente → gerenciador padrão (quando nada está no PATH)
# Usa correspondência por conteúdo: $XDG_CURRENT_DESKTOP pode ser uma lista
# separada por ':' (ex: "ubuntu:GNOME") ou variar por distro ("plasma").
de_default_fm() {
    case "${DE:-}" in
        *KDE*|*plasma*)  echo "dolphin" ;;
        *GNOME*)         echo "nautilus" ;;
        *XFCE*)          echo "thunar" ;;
        *Cinnamon*)      echo "nemo" ;;
        *MATE*)          echo "caja" ;;
        *LXDE*|*LXQt*)   echo "pcmanfm" ;;
        *)               return 1 ;;
    esac
}

ALL=0
[ "${1:-}" = "--all" ] && ALL=1

FMS=()
if [ "$ALL" -eq 1 ]; then
    echo "==> Modo --all: instalando em todos os gerenciadores suportados."
    FMS=(dolphin nautilus thunar nemo caja pcmanfm)
else
    for fm in dolphin nautilus thunar nemo caja pcmanfm pcmanfm-qt; do
        if command -v "$fm" >/dev/null 2>&1; then
            FMS+=("$fm")
        fi
    done
    if [ "${#FMS[@]}" -eq 0 ]; then
        if def="$(de_default_fm)"; then
            echo "    Nenhum gerenciador no PATH; usando o padrão do ambiente: $def"
            FMS=("$def")
        fi
    fi
fi

if [ "${#FMS[@]}" -eq 0 ]; then
    echo
    echo "Nenhum gerenciador de arquivos suportado foi encontrado."
    echo "Suportados: dolphin, nautilus, thunar, nemo, caja, pcmanfm."
    echo "Use '--all' para instalar em todos mesmo assim."
    exit 0
fi

echo "==> Gerenciadores alvo: ${FMS[*]}"

# ---------------------------------------------------------------------------
# Script auxiliar compartilhado (instalado uma única vez)
# ---------------------------------------------------------------------------
mkdir -p "$APP_DIR"
echo "==> Atualizando o script auxiliar..."
if ! curl -fsSL "$BASE_URL/raiw-helper.sh" -o "$HELPER"; then
    if [ -f "$HELPER" ]; then
        echo "    AVISO: falha ao baixar; mantendo o helper existente."
    else
        echo "    ERRO: não foi possível baixar o raiw-helper.sh de $BASE_URL"
        exit 1
    fi
fi
chmod +x "$HELPER"

# ---------------------------------------------------------------------------
# Instalação por gerenciador (via curl, no momento certo)
# ---------------------------------------------------------------------------
for fm in "${FMS[@]}"; do
    script="$(fm_script "$fm")" || continue
    echo
    echo "============================================================"
    echo " Instalando para: $fm"
    echo "============================================================"
    curl -fsSL "$BASE_URL/install-$script.sh" | bash
done

echo
echo "============================================================"
echo " Instalação concluída!"
echo "============================================================"
echo " Reinicie os gerenciadores para o menu aparecer."
echo "============================================================"