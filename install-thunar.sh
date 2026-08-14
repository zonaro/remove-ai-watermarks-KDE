#!/usr/bin/env bash
# =============================================================================
# Instala o menu de contexto "Remove AI Watermarks" no Thunar (XFCE).
#
# Abordagem: ações personalizadas (thunar-uca) em ~/.config/Thunar/uca.xml,
# agrupadas no submenu "Remove AI Watermarks".
#
# O que este script faz:
#   1. Garante o script auxiliar em ~/.local/share/remove-ai-watermarks-kde/
#   2. Insere (ou atualiza) as ações raiw-* no uca.xml, preservando as ações
#      existentes do usuário
#   3. As ações são idempotentes: re-executar apenas atualiza as raiw-*
# =============================================================================
set -euo pipefail

BASE_URL="${RAIW_BASE_URL:-https://raw.githubusercontent.com/zonaro/remove-ai-watermarks-KDE/main}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
APP_DIR="$DATA_DIR/remove-ai-watermarks-kde"
HELPER="$APP_DIR/raiw-helper.sh"
UCA="$CONFIG_DIR/Thunar/uca.xml"
ACTIONS_TMP="$(mktemp)"
trap 'rm -f "$ACTIONS_TMP"' EXIT

echo "==> Verificando o comando remove-ai-watermarks..."
if command -v remove-ai-watermarks >/dev/null 2>&1; then
    echo "    encontrado: $(remove-ai-watermarks --version 2>&1 | head -1)"
else
    echo "    AVISO: 'remove-ai-watermarks' não está no PATH."
    echo "    O menu será instalado, mas as ações falharão até o comando ser instalado."
fi

mkdir -p "$APP_DIR"

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
# Blocos <action> do Thunar (unique-ids raiw-*)
# ---------------------------------------------------------------------------
cat > "$ACTIONS_TMP" <<EOF
<action>
	<icon>search</icon>
	<name>Identify (identify)</name>
	<unique-id>raiw-identify</unique-id>
	<command>"$HELPER" identify %F</command>
	<description>Remove AI Watermarks — Identify</description>
	<patterns>*</patterns>
	<image-files/>
	<submenu>Remove AI Watermarks</submenu>
</action>
<action>
	<icon>draw-eraser</icon>
	<name>Remove visible mark (visible)</name>
	<unique-id>raiw-visible</unique-id>
	<command>"$HELPER" visible %F</command>
	<description>Remove AI Watermarks — Remove visible mark</description>
	<patterns>*</patterns>
	<image-files/>
	<submenu>Remove AI Watermarks</submenu>
</action>
<action>
	<icon>edit-delete</icon>
	<name>Remove AI metadata (metadata)</name>
	<unique-id>raiw-metadata</unique-id>
	<command>"$HELPER" metadata %F</command>
	<description>Remove AI Watermarks — Remove AI metadata</description>
	<patterns>*</patterns>
	<image-files/>
	<submenu>Remove AI Watermarks</submenu>
</action>
<action>
	<icon>edit-clear</icon>
	<name>Remove everything (all)</name>
	<unique-id>raiw-all</unique-id>
	<command>"$HELPER" all %F</command>
	<description>Remove AI Watermarks — Remove everything</description>
	<patterns>*</patterns>
	<image-files/>
	<submenu>Remove AI Watermarks</submenu>
</action>
<action>
	<icon>view-refresh</icon>
	<name>Batch process (visible)</name>
	<unique-id>raiw-batch</unique-id>
	<command>"$HELPER" batch %F</command>
	<description>Remove AI Watermarks — Batch process</description>
	<patterns>*</patterns>
	<directories/>
	<submenu>Remove AI Watermarks</submenu>
</action>
EOF

# ---------------------------------------------------------------------------
# Merge no uca.xml (preserva ações do usuário; remove/atualiza as raiw-*)
# ---------------------------------------------------------------------------
mkdir -p "$(dirname "$UCA")"

if [ -f "$UCA" ]; then
    echo "==> Atualizando $UCA (preservando suas ações)..."
    # 1. Remove blocos <action> raiw-* já existentes (idempotente)
    awk '
        BEGIN { in_action=0 }
        /<action>/ { in_action=1; buf=$0 "\n"; next }
        in_action {
            buf = buf $0 "\n"
            if ($0 ~ /<\/action>/) {
                if (buf ~ /raiw-/) { in_action=0; next }
                printf "%s", buf
                in_action=0
                next
            }
            next
        }
        { print }
    ' "$UCA" > "$UCA.tmp" && mv "$UCA.tmp" "$UCA"
    # 2. Insere os blocos novos antes de </actions>
    awk -v f="$ACTIONS_TMP" '
        /<\/actions>/ && !done {
            while ((getline line < f) > 0) print line
            close(f)
            done=1
        }
        { print }
    ' "$UCA" > "$UCA.tmp" && mv "$UCA.tmp" "$UCA"
else
    echo "==> Criando $UCA..."
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo '<actions>'
        cat "$ACTIONS_TMP"
        echo '</actions>'
    } > "$UCA"
fi

echo
echo "============================================================"
echo " Thunar (XFCE): instalação concluída!"
echo "============================================================"
echo " O submenu 'Remove AI Watermarks' aparecerá ao clicar com o"
echo " botão direito em imagens (Identify / Remove visible mark /"
echo " Remove AI metadata / Remove everything) e em pastas"
echo " (Batch process)."
echo
echo " Reinicie o Thunar (thunar -q) para o menu aparecer."
echo " Saída gerada: <nome>_ai_cleaned.<ext>"
echo "============================================================"