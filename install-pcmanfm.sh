#!/usr/bin/env bash
# =============================================================================
# Instala o menu de contexto "Remove AI Watermarks" no PCManFM (LXDE/LXQt).
#
# Abordagem: extensão DES-EMA (Desktop file specification extension) —
# arquivos .desktop Type=Action em ~/.local/share/file-manager/actions/.
#
# O que este script faz:
#   1. Garante o script auxiliar em ~/.local/share/remove-ai-watermarks-kde/
#   2. Cria 5 arquivos .desktop em ~/.local/share/file-manager/actions/
# =============================================================================
set -euo pipefail

BASE_URL="${RAIW_BASE_URL:-https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
APP_DIR="$DATA_DIR/remove-ai-watermarks-kde"
HELPER="$APP_DIR/raiw-helper.sh"
ACTIONS_DIR="$DATA_DIR/file-manager/actions"

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
# Ações DES-EMA (Type=Action + perfil X-Action-Profile)
# ---------------------------------------------------------------------------
write_action() { # $1=arquivo  $2=nome-en  $3=nome-pt  $4=nome-es  $5=ícone  $6=modo  $7=mime-types
    cat > "$ACTIONS_DIR/$1" <<EOF
[Desktop Entry]
Type=Action
Profiles=raiw-$6
Name=$2
Name[pt]=$3
Name[es]=$4
Icon=$5

[X-Action-Profile raiw-$6]
MimeTypes=$7
Exec="$HELPER" $6 %F
EOF
    echo "    criado: $ACTIONS_DIR/$1"
}

echo "==> Criando ações do PCManFM..."
IMG="image/*;"
write_action "remove-ai-watermarks-identify.desktop" "Identify (identify)" "Identificar (identify)" "Identificar (identify)" "search" "identify" "$IMG"
write_action "remove-ai-watermarks-visible.desktop" "Remove visible mark (visible)" "Remover marca visível (visible)" "Eliminar marca visible (visible)" "draw-eraser" "visible" "$IMG"
write_action "remove-ai-watermarks-metadata.desktop" "Remove AI metadata (metadata)" "Remover metadados AI (metadata)" "Eliminar metadatos IA (metadata)" "edit-delete" "metadata" "$IMG"
write_action "remove-ai-watermarks-all.desktop" "Remove everything (all)" "Remover tudo (all)" "Eliminar todo (all)" "edit-clear" "all" "$IMG"
write_action "remove-ai-watermarks-batch.desktop" "Batch process (visible)" "Processar em lote (visible)" "Procesar por lotes (visible)" "view-refresh" "batch" "all/allfiles;inode/directory;"

echo
echo "============================================================"
echo " PCManFM (LXDE/LXQt): instalação concluída!"
echo "============================================================"
echo " As ações aparecerão ao clicar com o botão direito em"
echo " imagens (Identify / Remove visible mark / Remove AI"
echo " metadata / Remove everything) e em arquivos/pastas"
echo " (Batch process)."
echo
echo " Reinicie o PCManFM para o menu aparecer."
echo " Saída gerada: <nome>_ai_cleaned.<ext>"
echo "============================================================"