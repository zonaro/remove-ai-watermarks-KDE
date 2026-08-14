#!/usr/bin/env bash
# =============================================================================
# Desinstalador de dependências "Remove AI Watermarks".
#
# Remove o CLI remove-ai-watermarks via uv. NÃO remove o uv nem o Python
# (são ferramentas genéricas que podem ser usadas por outros projetos).
#
# Chamado pelo uninstall.sh (com --deps ou após confirmação).
# Uso:
#   curl -fsSL <raw>/uninstall-deps.sh | bash
# =============================================================================
set -euo pipefail

if command -v uv >/dev/null 2>&1; then
    echo "==> Removendo remove-ai-watermarks via uv..."
    uv tool uninstall remove-ai-watermarks || true
else
    echo "==> uv não encontrado; nada a remover."
fi

if command -v remove-ai-watermarks >/dev/null 2>&1; then
    echo "    AVISO: remove-ai-watermarks ainda está no PATH: $(command -v remove-ai-watermarks)"
    echo "    Remova manualmente se desejar."
else
    echo "==> remove-ai-watermarks removido."
fi