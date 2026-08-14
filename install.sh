#!/usr/bin/env bash
# =============================================================================
# Instala o menu de contexto "Remove AI Watermarks" no Dolphin/Konqueror (KDE).
#
# O que este script faz:
#   1. Copia um script auxiliar para ~/.local/share/remove-ai-watermarks-kde/
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
# Script auxiliar (executa o remove-ai-watermarks e nomeia a saída _ai_cleaned)
# ---------------------------------------------------------------------------
cat > "$HELPER" <<'HELPER_EOF'
#!/usr/bin/env bash
# raiw-helper.sh — processa arquivos/pastas chamando o remove-ai-watermarks.
# Uso: raiw-helper.sh <identify|visible|metadata|all|batch> <arquivo|pasta>...
# Saída sempre nomeada: <nome>_ai_cleaned.<ext> (no mesmo diretório do original)
# Mensagens localizadas conforme o idioma do sistema (pt / es / en).
set -u

MODE="${1:-}"
shift 2>/dev/null || true

RAIW="$(command -v remove-ai-watermarks || true)"

# --- Localização (detecta o idioma do sistema via $LANG) ---------------------
case "${LANG:-}" in
    pt*)
        L_ERR="Remove AI Watermarks - ERRO"
        L_MODE="Modo não informado"
        L_NOTFOUND="remove-ai-watermarks não encontrado no PATH"
        L_NOFILE="Nenhum arquivo selecionado"
        L_FOLDER="Pasta selecionada: use a opção 'Processar em lote'"
        L_MISSING="Não encontrado: %s"
        L_DONE="%s arquivo(s) processado(s) com sucesso."
        L_FAIL="%s arquivo(s) falharam (%s processado(s)). Veja o terminal para detalhes."
        L_IDENT_FOUND="Marca(s) ou metadado(s) de IA encontrado(s) em %s:"
        L_IDENT_CLEAN="Nenhuma marca ou metadado de IA encontrado em %s."
        L_IDENT_FAIL="Falha ao analisar %s"
        ;;
    es*)
        L_ERR="Remove AI Watermarks - ERROR"
        L_MODE="Modo no especificado"
        L_NOTFOUND="remove-ai-watermarks no encontrado en el PATH"
        L_NOFILE="Ningún archivo seleccionado"
        L_FOLDER="Carpeta seleccionada: use la opción 'Procesar por lotes'"
        L_MISSING="No encontrado: %s"
        L_DONE="%s archivo(s) procesado(s) correctamente."
        L_FAIL="%s archivo(s) fallaron (%s procesado(s)). Vea la terminal para más detalles."
        L_IDENT_FOUND="Marca(s) o metadato(s) de IA encontrado(s) en %s:"
        L_IDENT_CLEAN="No se encontraron marcas ni metadatos de IA en %s."
        L_IDENT_FAIL="Error al analizar %s"
        ;;
    *)
        L_ERR="Remove AI Watermarks - ERROR"
        L_MODE="Mode not specified"
        L_NOTFOUND="remove-ai-watermarks not found in PATH"
        L_NOFILE="No file selected"
        L_FOLDER="Folder selected: use the 'Batch process' option"
        L_MISSING="Not found: %s"
        L_DONE="%s file(s) processed successfully."
        L_FAIL="%s file(s) failed (%s processed). See terminal for details."
        L_IDENT_FOUND="AI mark(s) or metadata found in %s:"
        L_IDENT_CLEAN="No AI mark or metadata found in %s."
        L_IDENT_FAIL="Failed to analyze %s"
        ;;
esac

notify() { # $1=título $2=mensagem
    if command -v kdialog >/dev/null 2>&1; then
        kdialog --title "$1" --passivepopup "$2" 5 >/dev/null 2>&1 || true
    fi
}
notify_err()  { notify "$L_ERR" "$1"; }
notify_done() { notify "Remove AI Watermarks" "$1"; }

show_dialog() { # $1=tipo (sorry|msgbox) $2=texto — exibe diálogo kdialog (ou stdout sem kdialog)
    if command -v kdialog >/dev/null 2>&1; then
        kdialog --title "Remove AI Watermarks - Identify" "$1" "$2" >/dev/null 2>&1 || true
    else
        printf '%s\n' "$2" >&2
    fi
}

# Analisa a imagem e exibe o resultado em um diálogo:
#   - ícone de ALERTA (--sorry) se encontrou marcas/metadados de IA
#   - ícone de SUCESSO (--msgbox) se não encontrou nada
identify_one() { # $1=arquivo
    local f="$1" out rc summary
    out="$("$RAIW" identify "$f" 2>&1)"
    rc=$?
    if [ "$rc" -ne 0 ]; then
        notify_err "$(printf "$L_IDENT_FAIL" "$(basename "$f")")"
        return "$rc"
    fi
    # resumo: da linha "Verdict:" até antes de "Caveats:"
    summary="$(printf '%s\n' "$out" | awk '/Caveats:/{exit} /Verdict:/{p=1} p')"
    if printf '%s\n' "$out" | grep -qE "Verdict: AI|Watermarks / provenance markers|Integrity clash"; then
        show_dialog sorry "$(printf "$L_IDENT_FOUND" "$(basename "$f")")\n\n$summary"
    else
        show_dialog msgbox "$(printf "$L_IDENT_CLEAN" "$(basename "$f")")\n\n$summary"
    fi
}

is_image() {
    case "$1" in
        *.jpg|*.jpeg|*.png|*.webp|*.bmp|*.tif|*.tiff|*.JPG|*.JPEG|*.PNG|*.WEBP|*.BMP|*.TIF|*.TIFF) return 0 ;;
    esac
    return 1
}

# <arquivo> -> <dir>/<nome>_ai_cleaned.<ext>
out_name() {
    local f="$1" dir base ext stem
    dir="$(dirname "$f")"
    base="$(basename "$f")"
    if [[ "$base" == *.* ]]; then
        ext="${base##*.}"
        stem="${base%.*}"
        printf '%s/%s_ai_cleaned.%s\n' "$dir" "$stem" "$ext"
    else
        printf '%s/%s_ai_cleaned\n' "$dir" "$base"
    fi
}

# $1=modo  $2=arquivo
process_one() {
    local mode="$1" f="$2" out
    case "$mode" in
        identify)
            identify_one "$f"
            ;;
        visible|metadata|all)
            out="$(out_name "$f")"
            "$RAIW" "$mode" "$f" -o "$out"
            ;;
        *)
            return 2
            ;;
    esac
}

# Processa todas as imagens (nível 1) da pasta no modo visible.
# Pula arquivos que já são saídas nossas (*_ai_cleaned.*).
batch_dir() {
    local dir="$1" f
    while IFS= read -r -d '' f; do
        is_image "$f" || continue
        case "$(basename "$f")" in *_ai_cleaned.*) continue ;; esac
        process_one visible "$f"
    done < <(find "$dir" -maxdepth 1 -type f -print0 2>/dev/null)
}

[ -n "$MODE" ]          || { notify_err "$L_MODE"; exit 2; }
[ -n "$RAIW" ]          || { notify_err "$L_NOTFOUND"; exit 1; }
[ "$#" -ge 1 ]          || { notify_err "$L_NOFILE"; exit 2; }

processed=0
errors=0

for target in "$@"; do
    if [ -d "$target" ]; then
        if [ "$MODE" = batch ]; then
            batch_dir "$target"
        else
            notify_err "$L_FOLDER"
            errors=$((errors + 1))
        fi
    elif [ -f "$target" ]; then
        if [ "$MODE" = batch ]; then
            process_one visible "$target" || errors=$((errors + 1))
        else
            process_one "$MODE" "$target" || errors=$((errors + 1))
        fi
        processed=$((processed + 1))
    else
        notify_err "$(printf "$L_MISSING" "$target")"
        errors=$((errors + 1))
    fi
done

if [ "$MODE" != identify ]; then
    if [ "$errors" -eq 0 ]; then
        notify_done "$(printf "$L_DONE" "$processed")"
    else
        notify_err "$(printf "$L_FAIL" "$errors" "$processed")"
    fi
fi
exit 0
HELPER_EOF

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
echo " Instalação concluída!"
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
