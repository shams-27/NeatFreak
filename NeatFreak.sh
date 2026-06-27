#!/bin/bash
set -euo pipefail

TARGET_DIR="$HOME/Downloads"
LOG_FILE="$TARGET_DIR/.neatfreak.log"
DRY_RUN=false
VERSION="2.0"

for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
done

# Nerd Font installer (runs once; skipped if marker or font already exists)
NF_DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
NF_MARKER="$HOME/.config/neatfreak/.nf_installed"

_nf_detect() {
    fc-list 2>/dev/null | grep -qi "nerd" && return 0
    ls "$HOME/.local/share/fonts" 2>/dev/null | grep -qi "nerd" && return 0
    ls "$HOME/Library/Fonts"      2>/dev/null | grep -qi "nerd" && return 0
    return 1
}

_nf_install_linux() {
    local font_dir="$HOME/.local/share/fonts/NeatFreak-NF"
    mkdir -p "$font_dir" /tmp/nf_extract
    printf "  \033[38;5;117m›\033[0m  downloading JetBrainsMono Nerd Font…\n"
    curl -fsSL "$NF_DOWNLOAD_URL" -o /tmp/nf_jbm.tar.xz
    tar -xf /tmp/nf_jbm.tar.xz -C /tmp/nf_extract/ --wildcards "*.ttf" 2>/dev/null || true
    cp /tmp/nf_extract/*.ttf "$font_dir/" 2>/dev/null || true
    rm -rf /tmp/nf_jbm.tar.xz /tmp/nf_extract
    fc-cache -f "$font_dir"
    printf "  \033[38;5;84m✓\033[0m  installed to %s\n" "$font_dir"
    printf "  \033[38;5;253m  → Set JetBrainsMono Nerd Font as your terminal font, then rerun.\033[0m\n\n"
}

_nf_install_macos() {
    local font_dir="$HOME/Library/Fonts"
    mkdir -p /tmp/nf_extract
    printf "  \033[38;5;117m›\033[0m  downloading JetBrainsMono Nerd Font…\n"
    curl -fsSL "$NF_DOWNLOAD_URL" -o /tmp/nf_jbm.tar.xz
    tar -xf /tmp/nf_jbm.tar.xz -C /tmp/nf_extract/ 2>/dev/null || true
    cp /tmp/nf_extract/*.ttf "$font_dir/" 2>/dev/null || true
    rm -rf /tmp/nf_jbm.tar.xz /tmp/nf_extract
    printf "  \033[38;5;84m✓\033[0m  installed to %s\n" "$font_dir"
    printf "  \033[38;5;253m  → Set JetBrainsMono Nerd Font as your terminal font, then rerun.\033[0m\n\n"
}

_nf_maybe_install() {
    [[ -f "$NF_MARKER" ]] && return
    _nf_detect && { mkdir -p "$(dirname "$NF_MARKER")"; touch "$NF_MARKER"; return; }

    printf "\n  \033[1m\033[38;5;255mNerd Font not detected\033[0m\n"
    printf "  \033[38;5;253mNeatFreak uses icons that need a Nerd Font. Install now? \033[0m\033[38;5;214m[Y/n]\033[0m "
    read -r answer </dev/tty
    [[ "$answer" =~ ^[Nn] ]] && { printf "  \033[38;5;245mSkipped — icons may appear as boxes.\033[0m\n\n"; return; }

    [[ "$(uname)" == "Darwin" ]] && _nf_install_macos || { mkdir -p /tmp/nf_extract; _nf_install_linux; }
    mkdir -p "$(dirname "$NF_MARKER")"; touch "$NF_MARKER"
}

_nf_maybe_install

# Colors
R='\033[0m';          BOLD='\033[1m'
G1='\033[38;5;84m';   G2='\033[38;5;78m'
CYAN='\033[38;5;117m'; BLUE='\033[38;5;75m';  PINK='\033[38;5;213m'
AMBER='\033[38;5;214m'; ORANGE='\033[38;5;215m'; RED='\033[38;5;203m'
PURPLE='\033[38;5;183m'; YELLOW='\033[38;5;222m'
W='\033[38;5;255m';   S1='\033[38;5;253m';  S2='\033[38;5;245m';  S3='\033[38;5;240m'
BAR_EMPTY='\033[38;5;237m'

folder_meta() {
    case "$1" in
        Images)        printf "${BLUE}󰋩 ${R}"   ;;
        Documents)     printf "${CYAN}󰈙 ${R}"   ;;
        Spreadsheets)  printf "${G1}󰈛 ${R}"    ;;
        Presentations) printf "${AMBER}󰈧 ${R}"  ;;
        Audio)         printf "${PINK}󰝚 ${R}"   ;;
        Video)         printf "${RED}󰕧 ${R}"    ;;
        Archives)      printf "${YELLOW}󰗄 ${R}" ;;
        Code)          printf "${G1}󰅩 ${R}"    ;;
        Installers)    printf "${ORANGE}󰏖 ${R}" ;;
        Fonts)         printf "${PURPLE}󰛖 ${R}" ;;
        *)             printf "${S2}󰈔 ${R}"    ;;
    esac
}

folder_color() {
    case "$1" in
        Images)        printf "${BLUE}"   ;;
        Documents)     printf "${CYAN}"   ;;
        Spreadsheets)  printf "${G1}"     ;;
        Presentations) printf "${AMBER}"  ;;
        Audio)         printf "${PINK}"   ;;
        Video)         printf "${RED}"    ;;
        Archives)      printf "${YELLOW}" ;;
        Code)          printf "${G1}"     ;;
        Installers)    printf "${ORANGE}" ;;
        Fonts)         printf "${PURPLE}" ;;
        *)             printf "${S2}"     ;;
    esac
}

draw_bar() {
    local current=$1 total=$2 width=36
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))
    local pct=$(( current * 100 / total ))
    local bar="" emptystr=""
    for (( i=0; i<filled-1; i++ )); do bar+="━"; done
    [[ $filled -gt 0 ]] && bar+="╸"
    for (( i=0; i<empty;   i++ )); do emptystr+="─"; done
    printf "  ${G1}%s${BAR_EMPTY}%s${R}  ${BOLD}${W}%3d%%${R}  ${S2}[%d/%d]${R}" \
        "$bar" "$emptystr" "$pct" "$current" "$total"
}

SPIN_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
spin_idx=0
spinner_tick() {
    printf "\r  ${CYAN}%s${R}  ${S1}%s${R}" "${SPIN_FRAMES[$spin_idx]}" "$1"
    spin_idx=$(( (spin_idx + 1) % ${#SPIN_FRAMES[@]} ))
}

log() {
    [[ "$DRY_RUN" == false ]] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "\n  ${RED}✖${R}  ${W}$TARGET_DIR${R}  ${S1}does not exist${R}\n" >&2; exit 1
fi

mapfile -t FILES < <(
    for f in "$TARGET_DIR"/*; do
        fname="$(basename "$f")"
        [ -d "$f" ] && continue
        [[ "$fname" == .* ]] && continue
        echo "$f"
    done
)
total=${#FILES[@]}

echo ""
for (( _i=0; _i<3; _i++ )); do spinner_tick "scanning $TARGET_DIR …"; sleep 0.05; done
printf "\r\033[K"

NOW="$(date '+%a %d %b  %H:%M')"
echo -e "  ${BOLD}${W}NeatFreak${R}  ${S2}v${VERSION}${R}  ${S2}·${R}  ${S2}${NOW}${R}"
echo -e "  ${S3}$(printf '%.0s─' {1..48})${R}"
echo -e "  ${S2}target${R}   ${S1}$TARGET_DIR${R}"
printf  "  ${S2}files${R}    ${BOLD}${W}%d${R}${S1} found${R}" "$total"
[[ "$DRY_RUN" == true ]] && printf "   ${S2}[${AMBER}DRY RUN${S2}]${R}\n" || printf "   ${S2}[${G1}LIVE${S2}]${R}\n"
echo -e "  ${S3}$(printf '%.0s─' {1..48})${R}"
echo ""

if [[ $total -eq 0 ]]; then
    echo -e "  ${G1}✓${R}  ${S1}already tidy — nothing to do${R}"; echo ""; exit 0
fi

draw_bar 0 "$total"; printf "\n"
printf "  ${S2}─${R}\n"
printf "  ${S1}starting…${R}\n"

TIME_START=$(date +%s)
moved_count=0; skipped_count=0; conflict_count=0; idx=0
declare -A folder_counts

for file in "${FILES[@]}"; do
    (( idx++ )) || true
    filename="$(basename "$file")"

    if [[ "$filename" != *.* ]]; then
        SUBFOLDER="No_Extension"; ext=""
    else
        ext="${filename##*.}"; ext="${ext,,}"
        case "$ext" in
            jpg|jpeg|png|gif|bmp|svg|webp|tiff|ico|heic)   SUBFOLDER="Images" ;;
            pdf|doc|docx|txt|rtf|odt|pages|md|epub)        SUBFOLDER="Documents" ;;
            xls|xlsx|csv|ods|numbers)                      SUBFOLDER="Spreadsheets" ;;
            ppt|pptx|key|odp)                              SUBFOLDER="Presentations" ;;
            mp3|wav|wma|m4a|flac|aac|ogg|opus)             SUBFOLDER="Audio" ;;
            mp4|mkv|mov|avi|wmv|flv|webm|m4v)              SUBFOLDER="Video" ;;
            zip|rar|7z|tar|gz|bz2|xz|zst)                 SUBFOLDER="Archives" ;;
            sh|py|js|ts|html|css|cpp|c|h|java|json|yaml|\
yml|toml|xml|rb|go|rs|php|sql|kt|swift)                   SUBFOLDER="Code" ;;
            exe|msi|dmg|pkg|deb|rpm|appimage)              SUBFOLDER="Installers" ;;
            ttf|otf|woff|woff2)                            SUBFOLDER="Fonts" ;;
            *)                                             SUBFOLDER="Miscellaneous" ;;
        esac
    fi

    DEST_DIR="$TARGET_DIR/$SUBFOLDER"
    DEST_FILE="$DEST_DIR/$filename"
    fc="$(folder_color "$SUBFOLDER")"
    fi_icon="$(folder_meta "$SUBFOLDER")"
    conflict=false

    if [ -f "$DEST_FILE" ]; then
        base="${filename%.*}"; stamp="$(date +%s)"
        DEST_FILE="$DEST_DIR/${base}_${stamp}${ext:+.$ext}"
        conflict=true; (( conflict_count++ )) || true
    fi

    now=$(date +%s); elapsed=$(( now - TIME_START ))
    if [[ $idx -gt 1 && $elapsed -gt 0 ]]; then
        rate=$(( idx / elapsed ))
        eta="$(( (total - idx) / (rate > 0 ? rate : 1) ))s"
    else
        eta="—"
    fi

    display="${filename:0:44}"
    [[ ${#filename} -gt 44 ]] && display="${display:0:43}…"

    tput cuu 3
    tput el; draw_bar "$idx" "$total"; printf "  ${S2}eta ${S1}%s${R}\n" "$eta"
    tput el; printf "  ${S2}─${R}\n"
    tput el
    if $conflict; then
        printf "  ${AMBER}⚡${R}  ${fi_icon}${S1}%-44s${R}  ${S2}→${R}  ${fc}%s${R}  ${AMBER}↺ renamed${R}\n" "$display" "$SUBFOLDER"
    elif [[ "$DRY_RUN" == true ]]; then
        printf "  ${S2}~${R}   ${fi_icon}${S2}%-44s${R}  ${S2}→  %s${R}\n" "$display" "$SUBFOLDER"
    else
        # Create folder if it doesn't exist
        if [ ! -d "$DEST_DIR" ]; then
            mkdir -p "$DEST_DIR"
        fi
        # Move the file
        mv "$file" "$DEST_DIR/"
        echo "Moved: $(basename "$file") -> /$SUBFOLDER"
    fi

done

echo "----------------------------------------"
echo "Process complete!"