#!/usr/bin/env bash
# =============================================================================
# Instala o menu de contexto "Remove AI Watermarks" no Nemo (Cinnamon).
#
# Abordagem: ações Nemo (.nemo_action) em ~/.local/share/nemo/actions/.
# Cada ação aparece como item no menu de contexto (Nemo não tem submenu).
#
# O que este script faz:
#   1. Garante o script auxiliar em ~/.local/share/remove-ai-watermarks-kde/
#   2. Cria 5 arquivos .nemo_action em ~/.local/share/nemo/actions/
#   3. Reinicia o Nemo (nemo -q) para o menu aparecer
# =============================================================================
set -euo pipefail

BASE_URL="${RAIW_BASE_URL:-https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-contextmenu/main}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
APP_DIR="$DATA_DIR/remove-ai-watermarks-kde"
HELPER="$APP_DIR/raiw-helper.sh"
ACTIONS_DIR="$DATA_DIR/nemo/actions"

echo "==> Verificando o comando remove-ai-watermarks..."
if command -v remove-ai-watermarks >/dev/null 2>&1; then
    echo "    encontrado: $(remove-ai-watermarks --version 2>&1 | head -1)"
else
    echo "    AVISO: 'remove-ai-watermarks' não está no PATH."
    echo "    O menu será instalado, mas as ações falharão até o comando ser instalado."
fi

mkdir -p "$APP_DIR" "$ACTIONS_DIR"

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
# Ações Nemo (o nome do arquivo é o identificador; o rótulo vem de Name)
# ---------------------------------------------------------------------------
write_action() { # $1=arquivo  $2=nome-en  $3=nome-pt  $4=nome-es  $5=ícone  $6=modo  $7=extensions
    cat > "$ACTIONS_DIR/$1" <<EOF
[Nemo Action]
Active=true
Name=$2
Name[pt]=$3
Name[es]=$4
Comment=Remove AI Watermarks — $2
Exec="$HELPER" $6 %F
Icon-Name=$5
Selection=notnone
Extensions=$7
Quote=double
EOF
    echo "    criado: $ACTIONS_DIR/$1"
}

echo "==> Criando ações do Nemo..."
IMG="jpg;jpeg;png;webp;bmp;tif;tiff;"
write_action "remove-ai-watermarks-identify.nemo_action" "Identify (identify)" "Identificar (identify)" "Identificar (identify)" "search" "identify" "$IMG"
write_action "remove-ai-watermarks-visible.nemo_action" "Remove visible mark (visible)" "Remover marca visível (visible)" "Eliminar marca visible (visible)" "draw-eraser" "visible" "$IMG"
write_action "remove-ai-watermarks-metadata.nemo_action" "Remove AI metadata (metadata)" "Remover metadados AI (metadata)" "Eliminar metadatos IA (metadata)" "edit-delete" "metadata" "$IMG"
write_action "remove-ai-watermarks-all.nemo_action" "Remove everything (all)" "Remover tudo (all)" "Eliminar todo (all)" "edit-clear" "all" "$IMG"
write_action "remove-ai-watermarks-batch.nemo_action" "Batch process (visible)" "Processar em lote (visible)" "Procesar por lotes (visible)" "view-refresh" "batch" "any;"

# ---------------------------------------------------------------------------
# Reinicia o Nemo para recarregar as ações
# ---------------------------------------------------------------------------
if command -v nemo >/dev/null 2>&1; then
    echo "==> Reiniciando o Nemo (nemo -q)..."
    nemo -q >/dev/null 2>&1 || true
fi

echo
echo "============================================================"
echo " Nemo (Cinnamon): instalação concluída!"
echo "============================================================"
echo " As ações aparecerão ao clicar com o botão direito em"
echo " imagens (Identify / Remove visible mark / Remove AI"
echo " metadata / Remove everything) e em qualquer seleção"
echo " (Batch process)."
echo
echo " Saída gerada: <nome>_ai_cleaned.<ext>"
echo "============================================================"