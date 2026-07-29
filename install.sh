#!/usr/bin/env bash

# ==============================================================================
# TOKYO NIGHT COLOR PALETTE ENGINE
# ==============================================================================

if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    BOLD='\033[1m'
    DIM='\033[2m'
    ITALIC='\033[3m'
    UNDERLINE='\033[4m'
    RESET='\033[0m'

    TN_PURPLE='\033[38;2;187;154;247m'  # #bb9af7 (Primary Magenta)
    TN_BLUE='\033[38;2;122;162;247m'    # #7aa2f7 (Secondary Blue)
    TN_CYAN='\033[38;2;125;207;255m'    # #7dcfff (Sky Blue)
    TN_TEAL='\033[38;2;115;218;202m'    # #73daca (Aqua / Teal)
    TN_GREEN='\033[38;2;158;206;106m'   # #9ece6a (Success Green)
    TN_YELLOW='\033[38;2;224;175;104m'  # #e0af68 (Warning Yellow)
    TN_ORANGE='\033[38;2;255;158;100m'  # #ff9e64 (Alert Orange)
    TN_RED='\033[38;2;247;118;142m'     # #f7768e (Error Red)
    TN_TEXT='\033[38;2;192;202;245m'    # #c0caf5 (Main Foreground)
    TN_MUTED='\033[38;2;86;95;137m'     # #565f89 (Comment Gray)

    BG_PURPLE='\033[48;2;187;154;247m\033[38;2;26;27;38m'
    BG_BLUE='\033[48;2;122;162;247m\033[38;2;26;27;38m'
    BG_GREEN='\033[48;2;158;206;106m\033[38;2;26;27;38m'
    BG_WARN='\033[48;2;224;175;104m\033[38;2;26;27;38m'
    BG_ERROR='\033[48;2;247;118;142m\033[38;2;26;27;38m'
else
    BOLD="" DIM="" ITALIC="" UNDERLINE="" RESET=""
    TN_PURPLE="" TN_BLUE="" TN_CYAN="" TN_TEAL="" TN_GREEN=""
    TN_YELLOW="" TN_ORANGE="" TN_RED="" TN_TEXT="" TN_MUTED=""
    BG_PURPLE="" BG_BLUE="" BG_GREEN="" BG_WARN="" BG_ERROR=""
fi

# ==============================================================================
# HELPER LOGGERS
# ==============================================================================

log_banner() {
    echo -e "\n${TN_PURPLE}${BOLD}┌────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${TN_PURPLE}${BOLD}│  🌙 $1${RESET}"
    echo -e "${TN_PURPLE}${BOLD}└────────────────────────────────────────────────────────┘${RESET}\n"
}

log_step() {
    echo -e " ${TN_CYAN}${BOLD}◈ $1${RESET}"
}

log_info() {
    echo -e "   ${TN_BLUE}🅸 ${TN_TEXT}$1${RESET}"
}

log_success() {
    echo -e "   ${TN_GREEN}✔ ${TN_TEXT}$1${RESET}"
}

log_warn() {
    echo -e "   ${TN_YELLOW}⚠ ${TN_TEXT}$1${RESET}"
}

log_error() {
    echo -e "   ${TN_RED}✖ ${TN_TEXT}$1${RESET}"
}

log_badge() {
    echo -e "   ${BG_PURPLE}${BOLD} $1 ${RESET} ${TN_TEXT}$2${RESET}"
}

log_dim() {
    echo -e "     ${TN_MUTED}┆ $1${RESET}"
}

# ==============================================================================
# SETUP SCRIPT EXECUTION
# ==============================================================================

log_banner "TOKYO NIGHT PERSONAL SETUP"

log_step "Step 1: Inisialisasi Lingkungan Kerja"
log_info "Memeriksa OS: $(uname -s) ($(uname -m))"
log_success "Sistem kompatibel."

echo ""
log_step "Step 2: Memeriksa & Memasang Ketergantungan"
log_info "Memeriksa perangkat lunak yang dibutuhkan..."

# Memeriksa & Memasang Homebrew
if command -v brew >/dev/null 2>&1; then
    log_success "Homebrew (brew) terdeteksi."
else
    log_warn "Homebrew (brew) tidak ditemukan. Memulai instalasi Homebrew..."
    log_dim "Mengunduh dan memasang Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        log_success "Homebrew berhasil dipasang."
    else
        log_error "Gagal memasang Homebrew."
    fi
fi

# Memeriksa & Memasang cURL
if command -v curl >/dev/null 2>&1; then
    log_success "cURL (curl) terdeteksi."
else
    log_warn "cURL (curl) tidak ditemukan. Memulai instalasi cURL..."
    if command -v brew >/dev/null 2>&1; then
        log_dim "Menginstal curl via Homebrew..."
        brew install curl
    fi
    if command -v curl >/dev/null 2>&1; then
        log_success "cURL berhasil dipasang."
    else
        log_error "Gagal memasang cURL."
    fi
fi

# Memeriksa & Memasang GitHub CLI
if command -v gh >/dev/null 2>&1; then
    log_success "GitHub CLI (gh) terdeteksi."
else
    log_warn "GitHub CLI (gh) tidak ditemukan. Memulai instalasi GitHub CLI (gh)..."
    if command -v brew >/dev/null 2>&1; then
        log_dim "Menginstal gh via Homebrew..."
        brew install gh
    fi
    if command -v gh >/dev/null 2>&1; then
        log_success "GitHub CLI (gh) berhasil dipasang."
    else
        log_error "Gagal memasang GitHub CLI (gh)."
    fi
fi

# Memeriksa & Memasang Oh My Zsh
if [ -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
    log_success "Oh My Zsh terdeteksi."
else
    log_warn "Oh My Zsh tidak ditemukan. Memulai instalasi Oh My Zsh..."
    log_dim "Mengunduh dan memasang Oh My Zsh..."
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        log_success "Oh My Zsh berhasil dipasang."
    else
        log_error "Gagal memasang Oh My Zsh."
    fi
fi
# ==============================================================================
# LANGUAGE VERSION MANAGER INSTALLERS WITH PRE-CHECKS
# ==============================================================================

install_nodejs_nvm() {
    export NVM_DIR="$HOME/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ] || command -v nvm >/dev/null 2>&1; then
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        log_success "NVM terdeteksi ($(node -v 2>/dev/null || echo 'Node.js aktif'))."
    else
        log_dim "NVM tidak ditemukan. Mengunduh dan memasang NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh 2>/dev/null | bash 2>/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        if command -v nvm >/dev/null 2>&1 || [ -s "$NVM_DIR/nvm.sh" ]; then
            log_dim "Menginstal Node.js versi terbaru (latest) via NVM..."
            nvm install node >/dev/null 2>&1
            nvm use node >/dev/null 2>&1
            nvm alias default node >/dev/null 2>&1
            log_success "NVM & Node.js versi terbaru berhasil dipasang."
        else
            log_error "Gagal memasang NVM / Node.js."
        fi
    fi
}

install_python_pyenv() {
    export PYENV_ROOT="$HOME/.pyenv"
    if command -v pyenv >/dev/null 2>&1 || [ -d "$PYENV_ROOT" ]; then
        log_success "pyenv (Python Version Manager) terdeteksi."
    else
        log_dim "pyenv tidak ditemukan. Memasang pyenv via Homebrew..."
        brew install pyenv 2>/dev/null
        if command -v pyenv >/dev/null 2>&1 || [ -f "$(brew --prefix 2>/dev/null)/bin/pyenv" ]; then
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init - 2>/dev/null)" || true
            log_dim "Menginstal Python 3 terbaru via pyenv..."
            latest_py=$(pyenv install --list 2>/dev/null | grep -E '^\s*3\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
            if [ -n "$latest_py" ]; then
                pyenv install -s "$latest_py" 2>/dev/null
                pyenv global "$latest_py" 2>/dev/null
                log_success "pyenv & Python ($latest_py) berhasil dipasang."
            else
                log_success "pyenv berhasil dipasang."
            fi
        else
            log_error "Gagal memasang pyenv."
        fi
    fi
}

install_go_goenv() {
    export GOENV_ROOT="$HOME/.goenv"
    if command -v goenv >/dev/null 2>&1 || [ -d "$GOENV_ROOT" ]; then
        log_success "goenv (Go Version Manager) terdeteksi."
    else
        log_dim "goenv tidak ditemukan. Memasang goenv via Homebrew..."
        brew install goenv 2>/dev/null
        if command -v goenv >/dev/null 2>&1 || [ -f "$(brew --prefix 2>/dev/null)/bin/goenv" ]; then
            export PATH="$GOENV_ROOT/bin:$PATH"
            eval "$(goenv init - 2>/dev/null)" || true
            log_dim "Menginstal Go versi terbaru via goenv..."
            latest_go=$(goenv install --list 2>/dev/null | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
            if [ -n "$latest_go" ]; then
                goenv install -s "$latest_go" 2>/dev/null
                goenv global "$latest_go" 2>/dev/null
                log_success "goenv & Go ($latest_go) berhasil dipasang."
            else
                log_success "goenv berhasil dipasang."
            fi
        else
            log_error "Gagal memasang goenv."
        fi
    fi
}

install_rust_rustup() {
    export CARGO_HOME="$HOME/.cargo"
    if command -v rustup >/dev/null 2>&1 || [ -f "$CARGO_HOME/bin/rustup" ]; then
        log_success "rustup (Rust Toolchain Manager) terdeteksi."
    else
        log_dim "rustup tidak ditemukan. Memulai instalasi Rustup..."
        if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs 2>/dev/null | sh -s -- -y 2>/dev/null; then
            [ -f "$CARGO_HOME/env" ] && \. "$CARGO_HOME/env"
            log_success "rustup & Rust toolchain ($(rustc --version 2>/dev/null || echo 'stable')) berhasil dipasang."
        else
            log_error "Gagal memasang rustup."
        fi
    fi
}

# ==============================================================================
# CATEGORY INSTALLERS
# ==============================================================================

install_programming_runtimes() {
    echo ""
    log_step "Memasang Programming Runtimes..."
    install_nodejs_nvm
    install_python_pyenv
    install_go_goenv
    install_rust_rustup
    log_dim "Menginstal Bun..."
    brew install bun 2>/dev/null || log_warn "bun sudah terinstal."
    log_success "Instalasi Programming Runtimes selesai."
}

install_dev_tools() {
    echo ""
    log_step "Memasang Development Tools..."
    local formula=("neovim" "tmux" "git")
    local casks=("visual-studio-code" "docker")
    for pkg in "${formula[@]}"; do
        log_dim "Menginstal $pkg..."
        brew install "$pkg" 2>/dev/null || log_warn "$pkg sudah terinstal."
    done
    for cask in "${casks[@]}"; do
        log_dim "Menginstal cask $cask..."
        brew install --cask "$cask" 2>/dev/null || log_warn "$cask sudah terinstal."
    done
    log_success "Instalasi Development Tools selesai."
}

install_entertainment_apps() {
    echo ""
    log_step "Memasang Entertainment Apps..."
    local casks=("vlc" "spotify" "stremio")
    for cask in "${casks[@]}"; do
        log_dim "Menginstal cask $cask..."
        brew install --cask "$cask" 2>/dev/null || log_warn "$cask sudah terinstal."
    done
    log_success "Instalasi Entertainment Apps selesai."
}

install_social_media_apps() {
    echo ""
    log_step "Memasang Social Media Apps..."
    local casks=("telegram" "whatsapp" "discord" "slack")
    for cask in "${casks[@]}"; do
        log_dim "Menginstal cask $cask..."
        brew install --cask "$cask" 2>/dev/null || log_warn "$cask sudah terinstal."
    done
    log_success "Instalasi Social Media Apps selesai."
}

# ==============================================================================
# CLEANUP AND SIGNAL HANDLERS
# ==============================================================================

cleanup_and_exit() {
    tput cnorm 2>/dev/null || true
    stty echo 2>/dev/null || true
    echo -e "\n\n   ${TN_RED}✖ Setup dibatalkan oleh pengguna (Ctrl+C).${RESET}\n"
    exit 130
}

trap 'cleanup_and_exit' INT TERM

# ==============================================================================
# INTERACTIVE CHECKBOX MULTI-SELECT MENU
# ==============================================================================

interactive_checkbox_menu() {
    local options=(
        "Node.js (via NVM)"
        "Python (via pyenv)"
        "Go (via goenv)"
        "Rust (via rustup)"
        "Bun"
        "Neovim"
        "Tmux"
        "Git"
        "Visual Studio Code"
        "Docker"
        "VLC"
        "Spotify"
        "Stremio"
        "Telegram"
        "WhatsApp"
        "Discord"
        "Slack"
    )

    local count=${#options[@]}
    local cur=0
    local selected=()
    for ((i=0; i<count; i++)); do selected[i]=0; done

    if [ ! -t 0 ]; then
        log_info "Sesi non-interaktif terdeteksi. Melewati instalasi aplikasi."
        return
    fi

    stty -echo
    tput civis

    draw_menu() {
        for ((i=0; i<count; i++)); do
            local mark
            if [ "${selected[i]}" -eq 1 ]; then
                mark="${TN_GREEN}[✔]${RESET}"
            else
                mark="${TN_MUTED}[ ]${RESET}"
            fi

            if [ "$i" -eq "$cur" ]; then
                echo -e " ${TN_PURPLE}${BOLD} ➜ ${mark} ${TN_CYAN}${BOLD}${options[i]}${RESET}\033[K"
            else
                echo -e "     ${mark} ${TN_TEXT}${options[i]}${RESET}\033[K"
            fi
        done
    }

    echo -e "   ${TN_TEXT}${BOLD}Pilih aplikasi yang ingin dipasang:${RESET}"
    echo -e "   ${TN_MUTED}(Navigasi: ⬆/⬇/j/k | Pilih: [Space] | Semua: [a] | Konfirmasi: [Enter] | Keluar: Ctrl+C)${RESET}\n"

    draw_menu

    while true; do
        IFS= read -sn1 key
        if [[ $key == $'\x1b' ]]; then
            read -sn2 key
            case "$key" in
                '[A') # UP arrow
                    ((cur--))
                    [ $cur -lt 0 ] && cur=$((count - 1))
                    ;;
                '[B') # DOWN arrow
                    ((cur++))
                    [ $cur -ge $count ] && cur=0
                    ;;
            esac
        elif [[ $key == "" ]]; then # ENTER key
            break
        elif [[ $key == $'\x03' || $key == $'\x04' ]]; then # Ctrl+C / Ctrl+D
            cleanup_and_exit
        elif [[ $key == " " ]]; then # SPACE key
            if [ "${selected[cur]}" -eq 1 ]; then
                selected[cur]=0
            else
                selected[cur]=1
            fi
        elif [[ $key == "a" || $key == "A" ]]; then # SELECT ALL / UNSELECT ALL
            local all_selected=1
            for ((i=0; i<count; i++)); do
                if [ "${selected[i]}" -eq 0 ]; then
                    all_selected=0
                    break
                fi
            done
            for ((i=0; i<count; i++)); do
                if [ "$all_selected" -eq 1 ]; then
                    selected[i]=0
                else
                    selected[i]=1
                fi
            done
        elif [[ $key == "k" || $key == "K" ]]; then # vim up
            ((cur--))
            [ $cur -lt 0 ] && cur=$((count - 1))
        elif [[ $key == "j" || $key == "J" ]]; then # vim down
            ((cur++))
            [ $cur -ge $count ] && cur=0
        fi

        echo -en "\033[${count}A"
        draw_menu
    done

    tput cnorm
    stty echo
    trap - EXIT INT TERM

    echo ""
    log_step "Memulai Instalasi Paket Terpilih..."

    local any_selected=0
    for ((i=0; i<count; i++)); do
        if [ "${selected[i]}" -eq 1 ]; then
            any_selected=1
            case $i in
                0) install_nodejs_nvm ;;
                1) install_python_pyenv ;;
                2) install_go_goenv ;;
                3) install_rust_rustup ;;
                4) log_dim "Menginstal bun..."; brew install bun 2>/dev/null || log_warn "bun sudah terinstal." ;;
                5) log_dim "Menginstal neovim..."; brew install neovim 2>/dev/null || log_warn "neovim sudah terinstal." ;;
                6) log_dim "Menginstal tmux..."; brew install tmux 2>/dev/null || log_warn "tmux sudah terinstal." ;;
                7) log_dim "Menginstal git..."; brew install git 2>/dev/null || log_warn "git sudah terinstal." ;;
                8) log_dim "Menginstal VS Code..."; brew install --cask visual-studio-code 2>/dev/null || log_warn "VS Code sudah terinstal." ;;
                9) log_dim "Menginstal Docker..."; brew install --cask docker 2>/dev/null || log_warn "Docker sudah terinstal." ;;
                10) log_dim "Menginstal VLC..."; brew install --cask vlc 2>/dev/null || log_warn "VLC sudah terinstal." ;;
                11) log_dim "Menginstal Spotify..."; brew install --cask spotify 2>/dev/null || log_warn "Spotify sudah terinstal." ;;
                12) log_dim "Menginstal Stremio..."; brew install --cask stremio 2>/dev/null || log_warn "Stremio sudah terinstal." ;;
                13) log_dim "Menginstal Telegram..."; brew install --cask telegram 2>/dev/null || log_warn "Telegram sudah terinstal." ;;
                14) log_dim "Menginstal WhatsApp..."; brew install --cask whatsapp 2>/dev/null || log_warn "WhatsApp sudah terinstal." ;;
                15) log_dim "Menginstal Discord..."; brew install --cask discord 2>/dev/null || log_warn "Discord sudah terinstal." ;;
                16) log_dim "Menginstal Slack..."; brew install --cask slack 2>/dev/null || log_warn "Slack sudah terinstal." ;;
            esac
        fi
    done

    if [ "$any_selected" -eq 0 ]; then
        log_info "Tidak ada aplikasi yang dipilih untuk diinstal."
    else
        log_success "Semua aplikasi yang dipilih telah selesai dipasang."
    fi
}

# ==============================================================================
# MENU SELECTION EXECUTION
# ==============================================================================

echo ""
log_step "Step 3: Pilih Paket Aplikasi yang Ingin Diinstal"
echo -e "   ${TN_TEXT}Pilih opsi instalasi yang Anda inginkan:${RESET}"
echo -e "   ${TN_PURPLE}1)${RESET} ${TN_TEXT}Programming Runtimes${RESET} ${TN_MUTED}(Node.js via NVM, Python via pyenv, Go via goenv, Rust via rustup, Bun)${RESET}"
echo -e "   ${TN_PURPLE}2)${RESET} ${TN_TEXT}Development Tools${RESET}    ${TN_MUTED}(VS Code, Neovim, Tmux, Docker, Git)${RESET}"
echo -e "   ${TN_PURPLE}3)${RESET} ${TN_TEXT}Entertainment Apps${RESET}   ${TN_MUTED}(VLC, Spotify, Stremio)${RESET}"
echo -e "   ${TN_PURPLE}4)${RESET} ${TN_TEXT}Social Media Apps${RESET}    ${TN_MUTED}(Telegram, WhatsApp, Discord, Slack)${RESET}"
echo -e "   ${TN_PURPLE}5)${RESET} ${TN_TEXT}Custom Selection${RESET}     ${TN_MUTED}(Daftar interaktif per-item dengan Spacebar [✔])${RESET}"
echo ""

if [ -t 0 ]; then
    read -rp "$(echo -e "${TN_CYAN}${BOLD}   Masukkan pilihan (misal: 1,2 atau 5 / 'all' / kosongkan untuk lewati): ${RESET}")" user_choice
else
    user_choice=""
fi

if [[ "$user_choice" =~ "all" || "$user_choice" =~ "ALL" ]]; then
    install_programming_runtimes
    install_dev_tools
    install_entertainment_apps
    install_social_media_apps
else
    [[ "$user_choice" =~ "1" ]] && install_programming_runtimes
    [[ "$user_choice" =~ "2" ]] && install_dev_tools
    [[ "$user_choice" =~ "3" ]] && install_entertainment_apps
    [[ "$user_choice" =~ "4" ]] && install_social_media_apps
    if [[ "$user_choice" =~ "5" ]]; then
        echo ""
        interactive_checkbox_menu
    fi
fi

