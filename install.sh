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

run_with_spinner() {
    local label="$1"
    local progress="$2"
    shift 2
    local cmd=("$@")

    local prefix=""
    if [ -n "$progress" ]; then
        prefix="${TN_MUTED}${progress}${RESET} "
    fi

    if [ ! -t 1 ]; then
        log_dim "${progress} Menginstal $label..."
        "${cmd[@]}" >/dev/null 2>&1
        return $?
    fi

    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local spin_count=${#frames[@]}
    local i=0

    tput civis 2>/dev/null || true

    "${cmd[@]}" >/tmp/tn_setup_cmd.log 2>&1 &
    local pid=$!

    while kill -0 $pid 2>/dev/null; do
        local frame="${frames[$i]}"
        echo -ne "\r     ${prefix}${TN_CYAN}${BOLD}${frame}${RESET} ${TN_TEXT}Menginstal ${TN_PURPLE}${BOLD}${label}${RESET}... ${TN_MUTED}(proses berlangsung)${RESET}\033[K"
        i=$(( (i + 1) % spin_count ))
        sleep 0.08
    done

    wait $pid 2>/dev/null
    local exit_code=$?

    tput cnorm 2>/dev/null || true

    if [ $exit_code -eq 0 ]; then
        echo -e "\r     ${prefix}${TN_GREEN}✔ ${TN_TEXT}${label} ${TN_GREEN}berhasil dipasang.${RESET}\033[K"
    else
        echo -e "\r     ${prefix}${TN_YELLOW}⚠ ${TN_TEXT}${label} ${TN_YELLOW}sudah terinstal atau tidak memerlukan pembaruan.${RESET}\033[K"
    fi

    return $exit_code
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
    run_with_spinner "Homebrew" "" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Memeriksa & Memasang cURL
if command -v curl >/dev/null 2>&1; then
    log_success "cURL (curl) terdeteksi."
else
    log_warn "cURL (curl) tidak ditemukan. Memulai instalasi cURL..."
    if command -v brew >/dev/null 2>&1; then
        run_with_spinner "cURL" "" brew install curl
    fi
fi

# Memeriksa & Memasang GitHub CLI
if command -v gh >/dev/null 2>&1; then
    log_success "GitHub CLI (gh) terdeteksi."
else
    log_warn "GitHub CLI (gh) tidak ditemukan. Memulai instalasi GitHub CLI (gh)..."
    if command -v brew >/dev/null 2>&1; then
        run_with_spinner "GitHub CLI" "" brew install gh
    fi
fi

# Memeriksa & Memasang Oh My Zsh
if [ -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
    log_success "Oh My Zsh terdeteksi."
else
    log_warn "Oh My Zsh tidak ditemukan. Memulai instalasi Oh My Zsh..."
    run_with_spinner "Oh My Zsh" "" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ==============================================================================
# LANGUAGE VERSION MANAGER INSTALLERS WITH PRE-CHECKS
# ==============================================================================

install_nodejs_nvm() {
    local progress="${1:-}"
    export NVM_DIR="$HOME/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ] || command -v nvm >/dev/null 2>&1; then
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        log_success "${progress:+$progress }NVM terdeteksi ($(node -v 2>/dev/null || echo 'Node.js aktif'))."
    else
        log_dim "${progress:+$progress }NVM tidak ditemukan. Mengunduh dan memasang NVM..."
        run_with_spinner "NVM" "$progress" bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh 2>/dev/null | bash"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        if command -v nvm >/dev/null 2>&1 || [ -s "$NVM_DIR/nvm.sh" ]; then
            run_with_spinner "Node.js (latest)" "$progress" bash -c "nvm install node && nvm alias default node"
        fi
    fi
}

install_python_pyenv() {
    local progress="${1:-}"
    export PYENV_ROOT="$HOME/.pyenv"
    if command -v pyenv >/dev/null 2>&1 || [ -d "$PYENV_ROOT" ]; then
        log_success "${progress:+$progress }pyenv (Python Version Manager) terdeteksi."
    else
        run_with_spinner "pyenv" "$progress" brew install pyenv
        if command -v pyenv >/dev/null 2>&1 || [ -f "$(brew --prefix 2>/dev/null)/bin/pyenv" ]; then
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init - 2>/dev/null)" || true
            latest_py=$(pyenv install --list 2>/dev/null | grep -E '^\s*3\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
            if [ -n "$latest_py" ]; then
                run_with_spinner "Python ($latest_py)" "$progress" bash -c "pyenv install -s $latest_py && pyenv global $latest_py"
            fi
        fi
    fi
}

install_go_goenv() {
    local progress="${1:-}"
    export GOENV_ROOT="$HOME/.goenv"
    if command -v goenv >/dev/null 2>&1 || [ -d "$GOENV_ROOT" ]; then
        log_success "${progress:+$progress }goenv (Go Version Manager) terdeteksi."
    else
        run_with_spinner "goenv" "$progress" brew install goenv
        if command -v goenv >/dev/null 2>&1 || [ -f "$(brew --prefix 2>/dev/null)/bin/goenv" ]; then
            export PATH="$GOENV_ROOT/bin:$PATH"
            eval "$(goenv init - 2>/dev/null)" || true
            latest_go=$(goenv install --list 2>/dev/null | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
            if [ -n "$latest_go" ]; then
                run_with_spinner "Go ($latest_go)" "$progress" bash -c "goenv install -s $latest_go && goenv global $latest_go"
            fi
        fi
    fi
}

install_rust_rustup() {
    local progress="${1:-}"
    export CARGO_HOME="$HOME/.cargo"
    if command -v rustup >/dev/null 2>&1 || [ -f "$CARGO_HOME/bin/rustup" ]; then
        log_success "${progress:+$progress }rustup (Rust Toolchain Manager) terdeteksi."
    else
        run_with_spinner "rustup" "$progress" bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
        [ -f "$CARGO_HOME/env" ] && \. "$CARGO_HOME/env"
    fi
}

# ==============================================================================
# CATEGORY INSTALLERS
# ==============================================================================

install_programming_runtimes() {
    echo ""
    log_step "Memasang Programming Runtimes..."
    install_nodejs_nvm "[1/5]"
    install_python_pyenv "[2/5]"
    install_go_goenv "[3/5]"
    install_rust_rustup "[4/5]"
    run_with_spinner "Bun" "[5/5]" brew install bun
    log_success "Instalasi Programming Runtimes selesai."
}

install_dev_tools() {
    echo ""
    log_step "Memasang Development Tools..."
    local formula=("neovim" "tmux" "git")
    local casks=("visual-studio-code" "docker")
    local total=$(( ${#formula[@]} + ${#casks[@]} ))
    local idx=1

    for pkg in "${formula[@]}"; do
        run_with_spinner "$pkg" "[$idx/$total]" brew install "$pkg"
        ((idx++))
    done
    for cask in "${casks[@]}"; do
        run_with_spinner "$cask" "[$idx/$total]" brew install --cask "$cask"
        ((idx++))
    done
    log_success "Instalasi Development Tools selesai."
}

install_entertainment_apps() {
    echo ""
    log_step "Memasang Entertainment Apps..."
    local casks=("vlc" "spotify" "stremio")
    local total=${#casks[@]}
    local idx=1
    for cask in "${casks[@]}"; do
        run_with_spinner "$cask" "[$idx/$total]" brew install --cask "$cask"
        ((idx++))
    done
    log_success "Instalasi Entertainment Apps selesai."
}

install_social_media_apps() {
    echo ""
    log_step "Memasang Social Media Apps..."
    local casks=("telegram" "whatsapp" "discord" "slack")
    local total=${#casks[@]}
    local idx=1
    for cask in "${casks[@]}"; do
        run_with_spinner "$cask" "[$idx/$total]" brew install --cask "$cask"
        ((idx++))
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

    local total_selected=0
    for ((i=0; i<count; i++)); do
        [ "${selected[i]}" -eq 1 ] && ((total_selected++))
    done

    local current_idx=1
    for ((i=0; i<count; i++)); do
        if [ "${selected[i]}" -eq 1 ]; then
            local progress="[$current_idx/$total_selected]"
            case $i in
                0) install_nodejs_nvm "$progress" ;;
                1) install_python_pyenv "$progress" ;;
                2) install_go_goenv "$progress" ;;
                3) install_rust_rustup "$progress" ;;
                4) run_with_spinner "Bun" "$progress" brew install bun ;;
                5) run_with_spinner "Neovim" "$progress" brew install neovim ;;
                6) run_with_spinner "Tmux" "$progress" brew install tmux ;;
                7) run_with_spinner "Git" "$progress" brew install git ;;
                8) run_with_spinner "VS Code" "$progress" brew install --cask visual-studio-code ;;
                9) run_with_spinner "Docker" "$progress" brew install --cask docker ;;
                10) run_with_spinner "VLC" "$progress" brew install --cask vlc ;;
                11) run_with_spinner "Spotify" "$progress" brew install --cask spotify ;;
                12) run_with_spinner "Stremio" "$progress" brew install --cask stremio ;;
                13) run_with_spinner "Telegram" "$progress" brew install --cask telegram ;;
                14) run_with_spinner "WhatsApp" "$progress" brew install --cask whatsapp ;;
                15) run_with_spinner "Discord" "$progress" brew install --cask discord ;;
                16) run_with_spinner "Slack" "$progress" brew install --cask slack ;;
            esac
            ((current_idx++))
        fi
    done

    if [ "$total_selected" -eq 0 ]; then
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

echo -e "\n${TN_TEAL}${ITALIC}✨ Setup Tokyo Night Selesai!${RESET}\n"
