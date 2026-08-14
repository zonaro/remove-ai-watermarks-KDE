#!/usr/bin/env bash
# =============================================================================
# Instalador de dependências "Remove AI Watermarks" — instala o CLI
# remove-ai-watermarks (https://github.com/wiltodelta/remove-ai-watermarks)
# e suas dependências, de acordo com a distro do usuário.
#
# Chamado pelo install.sh. Também pode ser executado isoladamente:
#   curl -fsSL <raw>/install-deps.sh | bash
#   curl -fsSL <raw>/install-deps.sh | bash -s -- --force   # reinstala
#
# Para testes locais, defina RAIW_BASE_URL (ex: file:///caminho/do/repo).
# =============================================================================
set -euo pipefail

# Extra do pacote (configurável via RAIW_EXTRA; default: all)
RAIW_EXTRA="${RAIW_EXTRA:-all}"
# Versão do Python usada pelo uv (3.12 cobre o trustmark em [all])
RAIW_PYTHON="${RAIW_PYTHON:-3.12}"

# Garante ~/.local/bin no PATH (onde o uv instala executáveis)
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

# ---------------------------------------------------------------------------
# 1. Já instalado? (pula, a menos que --force)
# ---------------------------------------------------------------------------
if [ "$FORCE" -eq 0 ] && command -v remove-ai-watermarks >/dev/null 2>&1; then
    echo "==> remove-ai-watermarks já instalado: $(command -v remove-ai-watermarks)"
    exit 0
fi

# ---------------------------------------------------------------------------
# 2. Detecção de distro (/etc/os-release)
# ---------------------------------------------------------------------------
DISTRO_ID="unknown"
DISTRO_LIKE=""
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_LIKE="${ID_LIKE:-}"
fi

# ---------------------------------------------------------------------------
# 3. Garante o uv (híbrido: pacote da distro → instalador oficial)
# ---------------------------------------------------------------------------
ensure_uv() {
    if command -v uv >/dev/null 2>&1; then
        echo "==> uv já instalado: $(command -v uv)"
        return 0
    fi

    echo "==> Instalando o uv (gerenciador de pacotes Python)..."
    case "$DISTRO_ID $DISTRO_LIKE" in
        *arch*)
            sudo pacman -S --noconfirm uv || true
            ;;
        *debian*|*ubuntu*)
            sudo apt-get update -y || true
            sudo apt-get install -y uv || true
            ;;
        *fedora*|*rhel*|*centos*|*rocky*|*alma*)
            sudo dnf install -y uv || true
            ;;
        *opensuse*|*suse*)
            sudo zypper install -y uv || true
            ;;
        *)
            echo "    Distro não mapeada ($DISTRO_ID); usando o instalador oficial."
            ;;
    esac

    if ! command -v uv >/dev/null 2>&1; then
        echo "    Usando o instalador oficial do uv (user-level, sem sudo)..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi

    if ! command -v uv >/dev/null 2>&1; then
        echo "    ERRO: não foi possível instalar o uv."
        exit 1
    fi
    echo "==> uv pronto: $(command -v uv)"
}

# ---------------------------------------------------------------------------
# 4. Garante um Python compatível (via uv)
# ---------------------------------------------------------------------------
ensure_python() {
    if uv python find "$RAIW_PYTHON" >/dev/null 2>&1; then
        echo "==> Python $RAIW_PYTHON já disponível."
        return 0
    fi
    echo "==> Instalando Python $RAIW_PYTHON via uv..."
    uv python install "$RAIW_PYTHON"
}

# ---------------------------------------------------------------------------
# 5. Instala o CLI remove-ai-watermarks
# ---------------------------------------------------------------------------
install_cli() {
    echo "==> Instalando remove-ai-watermarks[$RAIW_EXTRA] via uv..."
    uv tool install --force --python "$RAIW_PYTHON" "remove-ai-watermarks[$RAIW_EXTRA]"
}

# ---------------------------------------------------------------------------
# 6. Verificação final (PATH)
# ---------------------------------------------------------------------------
verify() {
    if command -v remove-ai-watermarks >/dev/null 2>&1; then
        echo "==> remove-ai-watermarks instalado: $(command -v remove-ai-watermarks)"
        echo
        echo "    Dica: se o menu de contexto falhar com 'não encontrado',"
        echo "    garanta que ~/.local/bin esteja no PATH do seu ambiente"
        echo "    (reabra o terminal ou faça logout/login)."
        return 0
    fi
    echo "    ERRO: remove-ai-watermarks não foi encontrado após a instalação."
    return 1
}

ensure_uv
ensure_python
install_cli
verify