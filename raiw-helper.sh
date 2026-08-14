#!/usr/bin/env bash
# raiw-helper.sh — processa arquivos/pastas chamando o remove-ai-watermarks.
# Uso: raiw-helper.sh <identify|visible|metadata|all|batch> <arquivo|pasta>...
# Saída sempre nomeada: <nome>_ai_cleaned.<ext> (no mesmo diretório do original)
# Mensagens localizadas conforme o idioma do sistema (pt / es / en).
#
# Este helper é compartilhado por todos os gerenciadores de arquivos suportados
# (Dolphin, Nautilus, Thunar, Nemo, Caja, PCManFM). Ele é instalado em:
#   $XDG_DATA_HOME/remove-ai-watermarks-kde/raiw-helper.sh
set -u

MODE="${1:-}"
shift 2>/dev/null || true

RAIW="$(command -v remove-ai-watermarks || true)"

# Log de diagnóstico — nunca falhar em silêncio
LOG="$(dirname "$0")/raiw.log"
log() { printf '%s %s\n' "$(date '+%F %T')" "$*" >> "$LOG" 2>/dev/null || true; }

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
        L_IDENT_FAIL="Falha ao analisar %s"
        L_IDENT_WORKING="Analisando %s... aguarde"
        L_TXT_HEADER="======= Remove AI Watermarks - Análise de IA ======="
        L_TXT_FILE=">>> Arquivo:"
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
        L_IDENT_FAIL="Error al analizar %s"
        L_IDENT_WORKING="Analizando %s... espere"
        L_TXT_HEADER="======= Remove AI Watermarks - Análisis de IA ======="
        L_TXT_FILE=">>> Archivo:"
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
        L_IDENT_FAIL="Failed to analyze %s"
        L_IDENT_WORKING="Analyzing %s... please wait"
        L_TXT_HEADER="======= Remove AI Watermarks - AI Analysis ======="
        L_TXT_FILE=">>> File:"
        ;;
esac

# Notificação — degrada conforme o ambiente (KDE/GNOME/XFCE/...), sempre com
# fallback para o log. Nunca falha em silêncio.
notify() { # $1=título $2=mensagem
    if command -v kdialog >/dev/null 2>&1; then
        kdialog --title "$1" --passivepopup "$2" 5 >/dev/null 2>&1 || log "kdialog passivepopup falhou"
    elif command -v zenity >/dev/null 2>&1; then
        zenity --notification --title "$1" --text "$2" >/dev/null 2>&1 || log "zenity notification falhou"
    elif command -v notify-send >/dev/null 2>&1; then
        notify-send "$1" "$2" >/dev/null 2>&1 || log "notify-send falhou"
    else
        log "nenhum notificador encontrado; popup suprimido"
    fi
}
notify_err()  { notify "$L_ERR" "$1"; }
notify_done() { notify "Remove AI Watermarks" "$1"; }

# <arquivo> -> <dir>/<stem>_ai_analysis.txt
out_txt_name() {
    local f="$1" dir base stem
    dir="$(dirname "$f")"
    base="$(basename "$f")"
    if [[ "$base" == *.* ]]; then stem="${base%.*}"; else stem="$base"; fi
    printf '%s/%s_ai_analysis.txt\n' "$dir" "$stem"
}

# Abre um arquivo com o visualizador padrão do sistema (multi-desktop)
open_file() { # $1=arquivo
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$1" >/dev/null 2>&1 &
        return 0
    fi
    for o in kde-open6 kde-open5 kde-open; do
        if command -v "$o" >/dev/null 2>&1; then
            "$o" "$1" >/dev/null 2>&1 &
            return 0
        fi
    done
    for o in kioclient6 kioclient5 kioclient; do
        if command -v "$o" >/dev/null 2>&1; then
            "$o" open "$1" >/dev/null 2>&1 &
            return 0
        fi
    done
    if command -v gio >/dev/null 2>&1; then
        gio open "$1" >/dev/null 2>&1 &
        return 0
    fi
    if command -v exo-open >/dev/null 2>&1; then
        exo-open "$1" >/dev/null 2>&1 &
        return 0
    fi
    log "nenhum abridor encontrado; análise salva em $1"
    return 1
}

# TXT acumulado da análise (modo identify)
IDENT_TXT=""
IDENT_COUNT=0

# Analisa a imagem e anexa o resultado ao TXT (aberto ao final).
identify_one() { # $1=arquivo
    local f="$1" out rc
    log "identify iniciado: $f"
    notify "Remove AI Watermarks - Identify" "$(printf "$L_IDENT_WORKING" "$(basename "$f")")"
    if [ -z "$IDENT_TXT" ]; then
        IDENT_TXT="$(out_txt_name "$f")"
        printf '%s\n%s\n\n' "$L_TXT_HEADER" "Data: $(date '+%Y-%m-%d %H:%M:%S')" > "$IDENT_TXT"
    fi
    out="$("$RAIW" identify "$f" 2>&1)"
    rc=$?
    if [ "$rc" -ne 0 ]; then
        log "identify falhou (rc=$rc): $f"
        notify_err "$(printf "$L_IDENT_FAIL" "$(basename "$f")")"
        return "$rc"
    fi
    {
        printf '%s %s\n' "$L_TXT_FILE" "$f"
        printf '%s\n' "$out"
        printf '%s\n' ''
    } >> "$IDENT_TXT"
    IDENT_COUNT=$((IDENT_COUNT + 1))
    log "identify concluído: $f (txt=$IDENT_TXT)"
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
    local mode="$1" f="$2" out rc
    case "$mode" in
        identify)
            identify_one "$f"
            ;;
        visible|metadata|all)
            out="$(out_name "$f")"
            log "$mode iniciado: $f"
            "$RAIW" "$mode" "$f" -o "$out"
            rc=$?
            if [ "$rc" -eq 0 ]; then
                log "$mode concluído: $f (out=$out)"
                return 0
            elif [ "$rc" -eq 2 ]; then
                # CLI: nenhuma marca/sinal detectado — nada a remover (não é erro)
                log "$mode: nenhuma marca detectada em $f (rc=2)"
                return 0
            else
                log "$mode falhou (rc=$rc): $f"
                return "$rc"
            fi
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

if [ "$MODE" = identify ]; then
    if [ "$IDENT_COUNT" -gt 0 ]; then
        log "identify: abrindo $IDENT_TXT"
        open_file "$IDENT_TXT"
    fi
else
    if [ "$errors" -eq 0 ]; then
        notify_done "$(printf "$L_DONE" "$processed")"
    else
        notify_err "$(printf "$L_FAIL" "$errors" "$processed")"
    fi
fi
exit 0