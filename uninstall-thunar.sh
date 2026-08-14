#!/usr/bin/env bash
# =============================================================================
# Desinstala o menu de contexto "Remove AI Watermarks" do Thunar (XFCE).
#
# Remove:
#   1. Os blocos <action> raiw-* do ~/.config/Thunar/uca.xml
#      (preserva as ações do usuário)
#   2. Se o uca.xml ficar sem nenhuma ação, remove o arquivo
#
# NÃO remove o script auxiliar compartilhado (o uninstall.sh principal cuida
# disso), nem o remove-ai-watermarks, nem os arquivos _ai_cleaned gerados.
# =============================================================================
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
UCA="$CONFIG_DIR/Thunar/uca.xml"

echo "==> Removendo ações raiw-* do Thunar..."
if [ -f "$UCA" ]; then
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

    if grep -q '<action>' "$UCA"; then
        echo "    ações raiw-* removidas; suas ações foram preservadas em $UCA"
    else
        rm -f "$UCA"
        echo "    uca.xml ficou sem ações; arquivo removido"
    fi
else
    echo "    (nada a remover)"
fi

echo
echo "============================================================"
echo " Thunar (XFCE): desinstalação concluída!"
echo "============================================================"
echo " Reinicie o Thunar (thunar -q) para o menu desaparecer."
echo "============================================================"