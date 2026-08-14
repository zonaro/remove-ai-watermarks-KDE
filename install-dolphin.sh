#!/usr/bin/env bash
# =============================================================================
# Instala o menu de contexto "Remove AI Watermarks" no Dolphin/Konqueror (KDE).
#
# O que este script faz:
#   1. Garante o script auxiliar em ~/.local/share/remove-ai-watermarks-kde/
#   2. Cria os ServiceMenus (.desktop) em ~/.local/share/kio/servicemenus/
#   3. Atualiza o cache do KDE (kbuildsycoca6)
#
# O menu aparece ao clicar com o botão direito em imagens, pastas ou
# seleção múltipla de imagens, com as opções:
#   - Identificar (identify)
#   - Remover marca visível (visible)
#   - Remover metadados AI (metadata --remove)
#   - Remover tudo (all)
#   - Processar em lote (visible)  <- apenas em pastas / múltiplas imagens
#
# O arquivo de saída sempre será: <nome_original>_ai_cleaned.<ext>
# =============================================================================
set -euo pipefail

BASE_URL="${RAIW_BASE_URL:-https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
MENU_DIR="$DATA_DIR/kio/servicemenus"
APP_DIR="$DATA_DIR/remove-ai-watermarks-kde"
HELPER="$APP_DIR/raiw-helper.sh"

echo "==> Verificando o comando remove-ai-watermarks..."
if command -v remove-ai-watermarks >/dev/null 2>&1; then
    echo "    encontrado: $(remove-ai-watermarks --version 2>&1 | head -1)"
else
    echo "    AVISO: 'remove-ai-watermarks' não está no PATH."
    echo "    O menu será instalado, mas as ações falharão até o comando ser instalado."
fi

mkdir -p "$MENU_DIR" "$APP_DIR"

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
# ServiceMenu para imagens (image/*)
# ---------------------------------------------------------------------------
cat > "$MENU_DIR/remove-ai-watermarks.desktop" <<EOF
[Desktop Entry]
Type=Service
Name=Remove AI Watermarks
ServiceTypes=KFileItemActions/Plugin;KonqPopupMenu/Plugin;
MimeType=image/*;
Actions=identify;visible;metadata;all;
X-KDE-Submenu=Remove AI Watermarks
X-KDE-Priority=TopLevel

[Desktop Action identify]
Name=Identify (identify)
Name[pt]=Identificar (identify)
Name[es]=Identificar (identify)
Icon=search
Exec="$HELPER" identify %F

[Desktop Action visible]
Name=Remove visible mark (visible)
Name[pt]=Remover marca visível (visible)
Name[es]=Eliminar marca visible (visible)
Icon=draw-eraser
Exec="$HELPER" visible %F

[Desktop Action metadata]
Name=Remove AI metadata (metadata)
Name[pt]=Remover metadados AI (metadata)
Name[es]=Eliminar metadatos IA (metadata)
Icon=edit-delete
Exec="$HELPER" metadata %F

[Desktop Action all]
Name=Remove everything (all)
Name[pt]=Remover tudo (all)
Name[es]=Eliminar todo (all)
Icon=edit-clear
Exec="$HELPER" all %F
EOF

# ---------------------------------------------------------------------------
# ServiceMenu para lote em múltiplas imagens (image/*, 2+ selecionadas)
# ---------------------------------------------------------------------------
cat > "$MENU_DIR/remove-ai-watermarks-batch.desktop" <<EOF
[Desktop Entry]
Type=Service
Name=Remove AI Watermarks (batch)
Name[pt]=Remove AI Watermarks (lote)
Name[es]=Remove AI Watermarks (lote)
ServiceTypes=KFileItemActions/Plugin;KonqPopupMenu/Plugin;
MimeType=image/*;
Actions=batch;
X-KDE-Submenu=Remove AI Watermarks
X-KDE-Priority=TopLevel
X-KDE-MinNumberOfUrls=2

[Desktop Action batch]
Name=Batch process (visible)
Name[pt]=Processar em lote (visible)
Name[es]=Procesar por lotes (visible)
Icon=view-refresh
Exec="$HELPER" batch %F
EOF

# ---------------------------------------------------------------------------
# ServiceMenu para pastas (inode/directory) — apenas lote
# ---------------------------------------------------------------------------
cat > "$MENU_DIR/remove-ai-watermarks-folders.desktop" <<EOF
[Desktop Entry]
Type=Service
Name=Remove AI Watermarks (folders)
Name[pt]=Remove AI Watermarks (pastas)
Name[es]=Remove AI Watermarks (carpetas)
ServiceTypes=KFileItemActions/Plugin;KonqPopupMenu/Plugin;
MimeType=inode/directory;
Actions=batch;
X-KDE-Submenu=Remove AI Watermarks
X-KDE-Priority=TopLevel

[Desktop Action batch]
Name=Batch process (visible)
Name[pt]=Processar em lote (visible)
Name[es]=Procesar por lotes (visible)
Icon=view-refresh
Exec="$HELPER" batch %F
EOF

# O KDE só autoriza executar ServiceMenus com o bit de execução
chmod +x "$MENU_DIR"/remove-ai-watermarks*.desktop

# ---------------------------------------------------------------------------
# Atualiza o cache do KDE
# ---------------------------------------------------------------------------
echo "==> Atualizando o cache do KDE (kbuildsycoca)..."
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 >/dev/null 2>&1 || true
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
    kbuildsycoca5 >/dev/null 2>&1 || true
else
    echo "    AVISO: kbuildsycoca não encontrado; o menu pode não aparecer até o próximo login."
fi

echo
echo "============================================================"
echo " Dolphin/Konqueror: instalação concluída!"
echo "============================================================"
echo " Arquivos instalados:"
echo "   $HELPER"
echo "   $MENU_DIR/remove-ai-watermarks.desktop"
echo "   $MENU_DIR/remove-ai-watermarks-batch.desktop"
echo "   $MENU_DIR/remove-ai-watermarks-folders.desktop"
echo
echo " Para o menu aparecer, reinicie o Dolphin:"
echo "   killall dolphin"
echo
echo " O menu 'Remove AI Watermarks' estará em:"
echo "   - Imagem única: Identificar / Remover marca visível /"
echo "                   Remover metadados / Remover tudo"
echo "   - Múltiplas imagens: + Processar em lote"
echo "   - Pastas: Processar em lote"
echo
echo " Saída gerada: <nome>_ai_cleaned.<ext>"
echo "============================================================"