#!/usr/bin/env bash
# =============================================================================
# Instala o menu de contexto "Remove AI Watermarks" no Nautilus (GNOME Files).
#
# Abordagem: scripts em ~/.local/share/nautilus/scripts/ (zero dependência).
# Uma subpasta "Remove AI Watermarks" cria um submenu dentro do menu "Scripts".
#
# O que este script faz:
#   1. Garante o script auxiliar em ~/.local/share/remove-ai-watermarks-kde/
#   2. Cria 5 scripts executáveis em:
#        ~/.local/share/nautilus/scripts/Remove AI Watermarks/
#   3. Reinicia o Nautilus (nautilus -q) para o menu aparecer
# =============================================================================
set -euo pipefail

BASE_URL="${RAIW_BASE_URL:-https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
APP_DIR="$DATA_DIR/remove-ai-watermarks-kde"
HELPER="$APP_DIR/raiw-helper.sh"
SCRIPT_DIR="$DATA_DIR/nautilus/scripts/Remove AI Watermarks"

echo "==> Verificando o comando remove-ai-watermarks..."
if command -v remove-ai-watermarks >/dev/null 2>&1; then
    echo "    encontrado: $(remove-ai-watermarks --version 2>&1 | head -1)"
else
    echo "    AVISO: 'remove-ai-watermarks' não está no PATH."
    echo "    O menu será instalado, mas as ações falharão até o comando ser instalado."
fi

mkdir -p "$APP_DIR" "$SCRIPT_DIR"

# ---------------------------------------------------------------------------
# Script auxiliar (compartilhado por todos os gerenciadores)
# ---------------------------------------------------------------------------
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
# Scripts do menu (o nome do arquivo é o rótulo exibido no submenu)
# ---------------------------------------------------------------------------
write_script() { # $1=nome do arquivo  $2=modo do helper
    cat > "$SCRIPT_DIR/$1" <<EOF
#!/usr/bin/env bash
# Remove AI Watermarks — $1
exec "$HELPER" $2 "\$@"
EOF
    chmod +x "$SCRIPT_DIR/$1"
    echo "    criado: $SCRIPT_DIR/$1"
}

echo "==> Criando scripts do menu (submenu 'Remove AI Watermarks')..."
write_script "Identify" identify
write_script "Remove visible mark" visible
write_script "Remove AI metadata" metadata
write_script "Remove everything" all
write_script "Batch process" batch

# ---------------------------------------------------------------------------
# Reinicia o Nautilus para recarregar os scripts
# ---------------------------------------------------------------------------
if command -v nautilus >/dev/null 2>&1; then
    echo "==> Reiniciando o Nautilus (nautilus -q)..."
    nautilus -q >/dev/null 2>&1 || true
fi

echo
echo "============================================================"
echo " Nautilus (GNOME Files): instalação concluída!"
echo "============================================================"
echo " O menu aparecerá em: Botão direito → Scripts →"
echo "   Remove AI Watermarks →"
echo "     - Identify"
echo "     - Remove visible mark"
echo "     - Remove AI metadata"
echo "     - Remove everything"
echo "     - Batch process"
echo
echo " Saída gerada: <nome>_ai_cleaned.<ext>"
echo "============================================================"