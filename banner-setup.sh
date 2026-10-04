#!/usr/bin/env bash
# ==============================================================================
# Project: Tmux-Pro Setup Tool#!/usr/bin/env bash
# ==============================================================================
# Project: Tmux-Pro Setup Tool
# Location: $HOME/Tmux-Pro/main-setup.sh
# Version: 4.0 (Final Hybrid Edition — v3.4 Base + Gemini 8 Features)
# Description: Automated setup script for Termux banner customization,
#              smart cross-shell configuration, prompt arrows & themes.
# Platform: Linux & Termux Only
# Menu: Pure D (Slanted Frame) + Full ASCII Header
# Prompt: managed by arrow-design.sh
# ==============================================================================

# ==========================================
# 🎨 COLOR VARIABLES
# ==========================================
RESET='\033[0m'
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
ORANGE='\033[38;5;208m'
PINK='\033[38;5;206m'
LIME='\033[38;5;118m'
MAGENTA='\033[1;35m'
GRAY='\033[38;5;242m'

# ==========================================
# 🛠 HELPER FUNCTIONS (printf — portable)
# ==========================================
print_step()    { printf "${MAGENTA}[*]${RESET} %s\n" "$1"; }
print_success() { printf "${GREEN}[+]${RESET} %s\n" "$1"; }
print_error()   { printf "${RED}[!] Error:${RESET} %s\n" "$1"; }
print_info()    { printf "${BLUE}[i]${RESET} %s\n" "$1"; }
print_warning() { printf "${YELLOW}[~]${RESET} %s\n" "$1"; }

# ==========================================
# 📁 PATH RESOLUTION (cwd independent)
# ==========================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
DIR="$SCRIPT_DIR"

# ==========================================
# ⚙️ ENVIRONMENT CHECK
# ==========================================
if [ -z "${PREFIX:-}" ]; then
    print_error "This script must be executed inside Termux environment."
    exit 1
fi

if [ ! -d "$DIR" ]; then
    print_error "Directory '$DIR' not found."
    print_info "Please execute from the repository directory: cd \$HOME/Tmux-Pro"
    exit 1
fi

# ==========================================
# ⏳ LOADING EFFECT (with fallback)
# ==========================================
if [ -f "$DIR/banner-logo/effect.sh" ]; then
    source "$DIR/banner-logo/effect.sh"
elif [ -f "$DIR/banner-logo/loading-effect.sh" ]; then
    source "$DIR/banner-logo/loading-effect.sh"
else
    show_loading() {
        print_info "$1..."
        sleep 1
    }
fi

# ==========================================
# 📁 CONFIG PATHS
# ==========================================
MOTD="$PREFIX/etc/motd"
BANNER_CONFIG="$HOME/.current-banner.sh"
BASH_RC="$PREFIX/etc/bash.bashrc"

# ── Zsh edge-case detection ──
ZSH_RC=""
if [ -f "$HOME/.zshrc" ]; then
    ZSH_RC="$HOME/.zshrc"
elif command -v zsh >/dev/null 2>&1; then
    ZSH_RC="$HOME/.zshrc"
elif [ -f "$PREFIX/etc/zshrc" ]; then
    ZSH_RC="$PREFIX/etc/zshrc"
fi

# ==========================================
# 💾 BACKUP LOGIC
# ==========================================
backup_files() {
    show_loading "Creating system backups"

    [ -f "$BASH_RC" ] && [ ! -f "$BASH_RC.bak" ] && cp -p "$BASH_RC" "$BASH_RC.bak"
    [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.bashrc.bak" ] && cp -p "$HOME/.bashrc" "$HOME/.bashrc.bak"
    [ -n "$ZSH_RC" ] && [ -f "$ZSH_RC" ] && [ ! -f "$ZSH_RC.bak" ] && cp -p "$ZSH_RC" "$ZSH_RC.bak"
    [ -f "$MOTD" ] && [ ! -f "$MOTD.bak" ] && cp -p "$MOTD" "$MOTD.bak"
}

# ==========================================
# 🎨 ARROW DESIGN HELPER (Y/N → launch)
# ==========================================
ask_arrow_design() {
    echo ""
    print_info "Do you want to change the Prompt Design (Arrow Styles)?"
    IFS= read -r -p "  👉 Choose (Y/N): " pc
    if [[ "$pc" =~ ^[Yy] ]]; then
        if [ -f "$DIR/banner-logo/arrow-design.sh" ]; then
            bash "$DIR/banner-logo/arrow-design.sh"
        else
            print_error "arrow-design.sh not found in $DIR/banner-logo/"
        fi
    else
        print_info "Skipped prompt design selection."
    fi
}

# ==========================================
# 🖌️ THEME HELPER (Y/N → launch)
# ==========================================
ask_theme() {
    echo ""
    print_info "Do you want to change the Terminal Theme?"
    IFS= read -r -p "  👉 Choose (Y/N): " tc
    if [[ "$tc" =~ ^[Yy] ]]; then
        if [ -f "$DIR/banner-logo/theme.sh" ]; then
            bash "$DIR/banner-logo/theme.sh"
        else
            print_error "theme.sh not found in $DIR/banner-logo/"
        fi
    else
        print_info "Skipped terminal theme."
    fi
}

# ==========================================
# 🚀 APPLY BANNER LOGIC (v4.0)
# ==========================================
apply_banner() {
    local BANNER_NAME="$1"
    local BANNER_FILE="$2"
    local TARGET_PATH=""

    # ── Multi-path fallback (၃ လမ်းကြောင်း) ──
    if [ -f "$DIR/banner-logo/Arts/$BANNER_FILE" ]; then
        TARGET_PATH="$DIR/banner-logo/Arts/$BANNER_FILE"
    elif [ -f "$DIR/banner-logo/$BANNER_FILE" ]; then
        TARGET_PATH="$DIR/banner-logo/$BANNER_FILE"
    elif [ -f "$DIR/$BANNER_FILE" ]; then
        TARGET_PATH="$DIR/$BANNER_FILE"
    fi

    # Name/System — file မလိုဘဲ generate
    if [ -z "$TARGET_PATH" ] && [ "$BANNER_FILE" != "name.sh" ]; then
        print_error "Banner file '$BANNER_FILE' not found!"
        print_info "  • $DIR/banner-logo/Arts/"
        print_info "  • $DIR/banner-logo/"
        print_info "  • $DIR/"
        sleep 2
        return 1
    fi

    print_step "Installing ${YELLOW}${BANNER_NAME}${RESET} banner..."
    backup_files

    # Clear MOTD
    if [ -f "$MOTD" ]; then : > "$MOTD"; else touch "$MOTD" 2>/dev/null; fi

    show_loading "Generating cross-shell configuration hook"

    # ── Write BANNER_CONFIG ──
    {
        echo "#!/data/data/com.termux/files/usr/bin/bash"
        echo "# Tmux-Pro — current banner config (v4.0)"
        echo "clear"

        if [[ "$BANNER_FILE" == "name.sh" ]]; then
            # ── Name/System banner (figlet + lolcat) ──
            echo 'if [ -f "$HOME/.banner-name" ]; then'
            echo '    NAME=$(cat "$HOME/.banner-name")'
            echo '    if command -v figlet >/dev/null 2>&1; then'
            echo '        if command -v lolcat >/dev/null 2>&1; then'
            echo '            figlet -f slant "$NAME" | lolcat'
            echo '        else'
            echo '            figlet -f slant "$NAME"'
            echo '        fi'
            echo '    else'
            echo '        echo "═══ $NAME ═══"'
            echo '    fi'
            echo 'fi'
        elif [[ "$TARGET_PATH" == *.sh ]]; then
            # ── Shell script banner ──
            echo "if [ -f \"$TARGET_PATH\" ]; then"
            echo "    source \"$TARGET_PATH\""
            echo "fi"
        else
            # ── Text file banner (runtime lolcat check) ──
            echo "if command -v lolcat >/dev/null 2>&1; then"
            echo "    [ -f \"$TARGET_PATH\" ] && cat \"$TARGET_PATH\" | lolcat"
            echo "else"
            echo "    [ -f \"$TARGET_PATH\" ] && cat \"$TARGET_PATH\""
            echo "fi"
        fi

        echo ""
        echo "# --- cmatrix alias ---"
        echo "alias matrix='cmatrix -b -s -C cyan' 2>/dev/null"
        echo ""
        echo "# --- Prompt (managed by arrow-design.sh) ---"
        echo "# TMUX-PRO PROMPT START"
        echo "[ -f \"\$HOME/.tmux-pro-prompt.sh\" ] && source \"\$HOME/.tmux-pro-prompt.sh\""
        echo "# TMUX-PRO PROMPT END"
    } > "$BANNER_CONFIG"
    chmod +x "$BANNER_CONFIG"

    # ── Hook into bash rc files ──
    for rc_file in "$BASH_RC" "$HOME/.bashrc"; do
        [ -n "$rc_file" ] && [ -f "$rc_file" ] || continue
        sed -i '/# TMUX-PRO HOOK START/,/# TMUX-PRO HOOK END/d' "$rc_file" 2>/dev/null
        {
            echo "# TMUX-PRO HOOK START"
            echo "[ -f \"$BANNER_CONFIG\" ] && source \"$BANNER_CONFIG\""
            echo "# TMUX-PRO HOOK END"
        } >> "$rc_file"
    done

    # ── Smart Zsh detection & hooking ──
    if command -v zsh >/dev/null 2>&1 || [ -f "$HOME/.zshrc" ]; then
        local zsh_target=""
        if [ -f "$HOME/.zshrc" ]; then
            zsh_target="$HOME/.zshrc"
        elif [ -f "$PREFIX/etc/zshrc" ]; then
            zsh_target="$PREFIX/etc/zshrc"
        elif command -v zsh >/dev/null 2>&1; then
            zsh_target="$HOME/.zshrc"
        fi

        if [ -n "$zsh_target" ]; then
            [ ! -f "$zsh_target" ] && touch "$zsh_target" 2>/dev/null
            sed -i '/# TMUX-PRO HOOK START/,/# TMUX-PRO HOOK END/d' "$zsh_target" 2>/dev/null
            {
                echo "# TMUX-PRO HOOK START"
                echo "[ -f \"$BANNER_CONFIG\" ] && source \"$BANNER_CONFIG\""
                echo "# TMUX-PRO HOOK END"
            } >> "$zsh_target"
        fi
    fi

    print_success "Banner '$BANNER_NAME' installed successfully!"
    return 0
}

# ==========================================
# 🖥️ HEADER (Full ASCII + Status Bar)
# ==========================================
show_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "   ████████╗███╗   ███╗██╗   ██╗██╗  ██╗    ██████╗ ██████╗  ██████╗"
    echo "   ╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝    ██╔══██╗██╔══██╗██╔═══██╗"
    echo "      ██║   ██╔████╔██║██║   ██║ ╚███╔╝     ██████╔╝██████╔╝██║   ██║"
    echo "      ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗     ██╔═══╝ ██╔══██╗██║   ██║"
    echo "      ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗    ██║     ██║  ██║╚██████╔╝"
    echo "      ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝"
    echo -e "${RESET}"
    echo -e "${PINK}${BOLD}  ◤ SYS.STATUS ◢ ${GREEN}● ONLINE${RESET}   ${PINK}${BOLD}◤ VER ◢ ${CYAN}v4.0${RESET}   ${PINK}${BOLD}◤ BY ◢ ${ORANGE}Art ${WHITE}& ${PINK}MarMu${RESET}"
    echo ""
}

# ==========================================
# 🖥️ MAIN MENU (Pure D — Slanted Frame)
# ==========================================
show_menu() {
    show_header

    # ── BANNER ARSENAL ──
    echo -e "${ORANGE}${BOLD}  ╱▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔╲${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}  ${CYAN}${BOLD}⟨ BANNER ARSENAL ⟩${RESET}                                             ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  ├──────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}                                                                  ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 01${RESET}  ${CYAN}👽  Alien${RESET}              ${WHITE}▸ Extraterrestrial${RESET}     ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 02${RESET}  ${CYAN}💀  Hacker${RESET}             ${WHITE}▸ Terminal Override${RESET}    ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 03${RESET}  ${CYAN}📡  Cyber Matrix${RESET}       ${WHITE}▸ Digital Rain${RESET}         ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 04${RESET}  ${CYAN}🐺  Wolf${RESET}               ${WHITE}▸ Lone Predator${RESET}        ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 05${RESET}  ${CYAN}🕷️   Spider${RESET}             ${WHITE}▸ Web Weaver${RESET}           ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 06${RESET}  ${CYAN}🦇  Bat${RESET}                ${WHITE}▸ Night Shadow${RESET}         ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 07${RESET}  ${CYAN}🦞  Lobster${RESET}            ${WHITE}▸ Deep Claw${RESET}            ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 08${RESET}  ${CYAN}💀  Matrix Skull${RESET}       ${WHITE}▸ Neon Reaper${RESET}          ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 09${RESET}  ${CYAN}🐉  Cyber Dragon${RESET}       ${WHITE}▸ Chrome Wyrm${RESET}          ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 10${RESET}  ${CYAN}✒️   Name / System${RESET}      ${WHITE}▸ Personal Sigil${RESET}       ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}                                                                  ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  ╲▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁╱${RESET}"
    echo ""

    # ── CUSTOMIZATION ──
    echo -e "${YELLOW}${BOLD}  ╱▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔╲${RESET}"
    echo -e "${YELLOW}${BOLD}  │${RESET}  ${CYAN}${BOLD}⟨ CUSTOMIZATION ⟩${RESET}                                             ${YELLOW}${BOLD}│${RESET}"
    echo -e "${YELLOW}${BOLD}  ├──────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${YELLOW}${BOLD}  │${RESET}                                                                  ${YELLOW}${BOLD}│${RESET}"
    echo -e "${YELLOW}${BOLD}  │${RESET}   ${MAGENTA}${BOLD}⟩⟩ 11${RESET}  ${MAGENTA}🎨  Prompt Design${RESET}     ${WHITE}▸ Arrow Styles${RESET}         ${YELLOW}${BOLD}│${RESET}"
    echo -e "${YELLOW}${BOLD}  │${RESET}   ${MAGENTA}${BOLD}⟩⟩ 12${RESET}  ${MAGENTA}🖌️   Terminal Theme${RESET}    ${WHITE}▸ Color Schemes${RESET}        ${YELLOW}${BOLD}│${RESET}"
    echo -e "${YELLOW}${BOLD}  │${RESET}                                                                  ${YELLOW}${BOLD}│${RESET}"
    echo -e "${YELLOW}${BOLD}  ╲▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁╱${RESET}"
    echo ""

    # ── DANGER ZONE ──
    echo -e "${RED}${BOLD}  ╱▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔╲${RESET}"
    echo -e "${RED}${BOLD}  │${RESET}  ${ORANGE}${BOLD}⟨ DANGER ZONE ⟩${RESET}                                               ${RED}${BOLD}│${RESET}"
    echo -e "${RED}${BOLD}  ├──────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${RED}${BOLD}  │${RESET}                                                                  ${RED}${BOLD}│${RESET}"
    echo -e "${RED}${BOLD}  │${RESET}   ${ORANGE}${BOLD}⟩⟩ 13${RESET}  ${ORANGE}🔄  Restore Original${RESET}  ${WHITE}▸ Revert Changes${RESET}        ${RED}${BOLD}│${RESET}"
    echo -e "${RED}${BOLD}  │${RESET}   ${ORANGE}${BOLD}⟩⟩ 00${RESET}  ${RED}❌  Exit${RESET}              ${WHITE}▸ Terminate${RESET}            ${RED}${BOLD}│${RESET}"
    echo -e "${RED}${BOLD}  │${RESET}                                                                  ${RED}${BOLD}│${RESET}"
    echo -e "${RED}${BOLD}  ╲▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁╱${RESET}"
    echo ""

    # ── Input Prompt ──
    echo -ne "${ORANGE}${BOLD}  ╭─[${CYAN}root@tmux-pro${ORANGE}]─[${PINK}~${ORANGE}]${RESET}\n${ORANGE}${BOLD}  ╰──► ${RESET}"
}

# ==========================================
# 🔁 MAIN LOOP
# ==========================================
while true; do
    show_menu
    IFS= read -r choice

    case "$choice" in
        1|01)
            if apply_banner "Alien" "alien.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        2|02)
            if apply_banner "Hacker" "hacker.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        3|03)
            if apply_banner "Cyber Matrix" "cyber.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        4|04)
            if apply_banner "Wolf" "wolf.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        5|05)
            if apply_banner "Spider" "spider.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        6|06)
            if apply_banner "Bat" "bat.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        7|07)
            if apply_banner "Lobster" "lobster.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        8|08)
            if apply_banner "Matrix Skull" "matrix-skull.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        9|09)
            if apply_banner "Cyber Dragon" "cyber-dragon.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        10)
            echo ""
            print_info "Enter your custom display name:"
            IFS= read -r -p "  👉 Name: " banner_name
            if [ -n "$banner_name" ]; then
                printf '%s\n' "$banner_name" > "$HOME/.banner-name"
                if apply_banner "Name/System" "name.sh"; then
                    ask_arrow_design; ask_theme
                    echo ""
                    print_success "Setup complete! Restart your shell to see changes."
                    sleep 2
                fi
            else
                print_error "Name cannot be empty!"
                sleep 1
            fi
            ;;
        11)
            if [ -f "$DIR/banner-logo/arrow-design.sh" ]; then
                bash "$DIR/banner-logo/arrow-design.sh"
            else
                print_error "arrow-design.sh not found"
                sleep 1
            fi
            ;;
        12)
            if [ -f "$DIR/banner-logo/theme.sh" ]; then
                bash "$DIR/banner-logo/theme.sh"
            else
                print_error "theme.sh not found"
                sleep 1
            fi
            ;;
        13)
            if [ -f "$DIR/banner-logo/restore-original.sh" ]; then
                show_loading "Restoring original settings"
                bash "$DIR/banner-logo/restore-original.sh"
            else
                print_error "restore-original.sh not found"
                sleep 2
            fi
            ;;
        0|00)
            print_success "Exiting... Happy Coding!"
            exit 0
            ;;
        *)
            print_warning "Invalid option! Choose 0-13"
            sleep 1
            continue
            ;;
    esac
done
# Location: $HOME/Tmux-Pro/main-setup.sh
# Version: 4.0 (Final Hybrid Edition — v3.4 Base + Gemini 8 Features)
# Description: Automated setup script for Termux banner customization,
#              smart cross-shell configuration, prompt arrows & themes.
# Platform: Linux & Termux Only
# Menu: Pure D (Slanted Frame) + Full ASCII Header
# Prompt: managed by arrow-design.sh
# ==============================================================================

# ==========================================
# 🎨 COLOR VARIABLES
# ==========================================
RESET='\033[0m'
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
ORANGE='\033[38;5;208m'
PINK='\033[38;5;206m'
LIME='\033[38;5;118m'
MAGENTA='\033[1;35m'
GRAY='\033[38;5;242m'

# ==========================================
# 🛠 HELPER FUNCTIONS (printf — portable)
# ==========================================
print_step()    { printf "${MAGENTA}[*]${RESET} %s\n" "$1"; }
print_success() { printf "${GREEN}[+]${RESET} %s\n" "$1"; }
print_error()   { printf "${RED}[!] Error:${RESET} %s\n" "$1"; }
print_info()    { printf "${BLUE}[i]${RESET} %s\n" "$1"; }
print_warning() { printf "${YELLOW}[~]${RESET} %s\n" "$1"; }

# ==========================================
# 📁 PATH RESOLUTION (cwd independent)
# ==========================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
DIR="$SCRIPT_DIR"

# ==========================================
# ⚙️ ENVIRONMENT CHECK
# ==========================================
if [ -z "${PREFIX:-}" ]; then
    print_error "This script must be executed inside Termux environment."
    exit 1
fi

if [ ! -d "$DIR" ]; then
    print_error "Directory '$DIR' not found."
    print_info "Please execute from the repository directory: cd \$HOME/Tmux-Pro"
    exit 1
fi

# ==========================================
# ⏳ LOADING EFFECT (with fallback)
# ==========================================
if [ -f "$DIR/banner-logo/effect.sh" ]; then
    source "$DIR/banner-logo/effect.sh"
elif [ -f "$DIR/banner-logo/loading-effect.sh" ]; then
    source "$DIR/banner-logo/loading-effect.sh"
else
    show_loading() {
        print_info "$1..."
        sleep 1
    }
fi

# ==========================================
# 📁 CONFIG PATHS
# ==========================================
MOTD="$PREFIX/etc/motd"
BANNER_CONFIG="$HOME/.current-banner.sh"
BASH_RC="$PREFIX/etc/bash.bashrc"

# ── Zsh edge-case detection ──
ZSH_RC=""
if [ -f "$HOME/.zshrc" ]; then
    ZSH_RC="$HOME/.zshrc"
elif command -v zsh >/dev/null 2>&1; then
    ZSH_RC="$HOME/.zshrc"
elif [ -f "$PREFIX/etc/zshrc" ]; then
    ZSH_RC="$PREFIX/etc/zshrc"
fi

# ==========================================
# 💾 BACKUP LOGIC
# ==========================================
backup_files() {
    show_loading "Creating system backups"

    [ -f "$BASH_RC" ] && [ ! -f "$BASH_RC.bak" ] && cp -p "$BASH_RC" "$BASH_RC.bak"
    [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.bashrc.bak" ] && cp -p "$HOME/.bashrc" "$HOME/.bashrc.bak"
    [ -n "$ZSH_RC" ] && [ -f "$ZSH_RC" ] && [ ! -f "$ZSH_RC.bak" ] && cp -p "$ZSH_RC" "$ZSH_RC.bak"
    [ -f "$MOTD" ] && [ ! -f "$MOTD.bak" ] && cp -p "$MOTD" "$MOTD.bak"
}

# ==========================================
# 🎨 ARROW DESIGN HELPER (Y/N → launch)
# ==========================================
ask_arrow_design() {
    echo ""
    print_info "Do you want to change the Prompt Design (Arrow Styles)?"
    IFS= read -r -p "  👉 Choose (Y/N): " pc
    if [[ "$pc" =~ ^[Yy] ]]; then
        if [ -f "$DIR/banner-logo/arrow-design.sh" ]; then
            bash "$DIR/banner-logo/arrow-design.sh"
        else
            print_error "arrow-design.sh not found in $DIR/banner-logo/"
        fi
    else
        print_info "Skipped prompt design selection."
    fi
}

# ==========================================
# 🖌️ THEME HELPER (Y/N → launch)
# ==========================================
ask_theme() {
    echo ""
    print_info "Do you want to change the Terminal Theme?"
    IFS= read -r -p "  👉 Choose (Y/N): " tc
    if [[ "$tc" =~ ^[Yy] ]]; then
        if [ -f "$DIR/banner-logo/theme.sh" ]; then
            bash "$DIR/banner-logo/theme.sh"
        else
            print_error "theme.sh not found in $DIR/banner-logo/"
        fi
    else
        print_info "Skipped terminal theme."
    fi
}

# ==========================================
# 🚀 APPLY BANNER LOGIC (v4.0)
# ==========================================
apply_banner() {
    local BANNER_NAME="$1"
    local BANNER_FILE="$2"
    local TARGET_PATH=""

    # ── Multi-path fallback (၃ လမ်းကြောင်း) ──
    if [ -f "$DIR/banner-logo/Arts/$BANNER_FILE" ]; then
        TARGET_PATH="$DIR/banner-logo/Arts/$BANNER_FILE"
    elif [ -f "$DIR/banner-logo/$BANNER_FILE" ]; then
        TARGET_PATH="$DIR/banner-logo/$BANNER_FILE"
    elif [ -f "$DIR/$BANNER_FILE" ]; then
        TARGET_PATH="$DIR/$BANNER_FILE"
    fi

    # Name/System — file မလိုဘဲ generate
    if [ -z "$TARGET_PATH" ] && [ "$BANNER_FILE" != "name.sh" ]; then
        print_error "Banner file '$BANNER_FILE' not found!"
        print_info "  • $DIR/banner-logo/Arts/"
        print_info "  • $DIR/banner-logo/"
        print_info "  • $DIR/"
        sleep 2
        return 1
    fi

    print_step "Installing ${YELLOW}${BANNER_NAME}${RESET} banner..."
    backup_files

    # Clear MOTD
    if [ -f "$MOTD" ]; then : > "$MOTD"; else touch "$MOTD" 2>/dev/null; fi

    show_loading "Generating cross-shell configuration hook"

    # ── Write BANNER_CONFIG ──
    {
        echo "#!/data/data/com.termux/files/usr/bin/bash"
        echo "# Tmux-Pro — current banner config (v4.0)"
        echo "clear"

        if [[ "$BANNER_FILE" == "name.sh" ]]; then
            # ── Name/System banner (figlet + lolcat) ──
            echo 'if [ -f "$HOME/.banner-name" ]; then'
            echo '    NAME=$(cat "$HOME/.banner-name")'
            echo '    if command -v figlet >/dev/null 2>&1; then'
            echo '        if command -v lolcat >/dev/null 2>&1; then'
            echo '            figlet -f slant "$NAME" | lolcat'
            echo '        else'
            echo '            figlet -f slant "$NAME"'
            echo '        fi'
            echo '    else'
            echo '        echo "═══ $NAME ═══"'
            echo '    fi'
            echo 'fi'
        elif [[ "$TARGET_PATH" == *.sh ]]; then
            # ── Shell script banner ──
            echo "if [ -f \"$TARGET_PATH\" ]; then"
            echo "    source \"$TARGET_PATH\""
            echo "fi"
        else
            # ── Text file banner (runtime lolcat check) ──
            echo "if command -v lolcat >/dev/null 2>&1; then"
            echo "    [ -f \"$TARGET_PATH\" ] && cat \"$TARGET_PATH\" | lolcat"
            echo "else"
            echo "    [ -f \"$TARGET_PATH\" ] && cat \"$TARGET_PATH\""
            echo "fi"
        fi

        echo ""
        echo "# --- cmatrix alias ---"
        echo "alias matrix='cmatrix -b -s -C cyan' 2>/dev/null"
        echo ""
        echo "# --- Prompt (managed by arrow-design.sh) ---"
        echo "# TMUX-PRO PROMPT START"
        echo "[ -f \"\$HOME/.tmux-pro-prompt.sh\" ] && source \"\$HOME/.tmux-pro-prompt.sh\""
        echo "# TMUX-PRO PROMPT END"
    } > "$BANNER_CONFIG"
    chmod +x "$BANNER_CONFIG"

    # ── Hook into bash rc files ──
    for rc_file in "$BASH_RC" "$HOME/.bashrc"; do
        [ -n "$rc_file" ] && [ -f "$rc_file" ] || continue
        sed -i '/# TMUX-PRO HOOK START/,/# TMUX-PRO HOOK END/d' "$rc_file" 2>/dev/null
        {
            echo "# TMUX-PRO HOOK START"
            echo "[ -f \"$BANNER_CONFIG\" ] && source \"$BANNER_CONFIG\""
            echo "# TMUX-PRO HOOK END"
        } >> "$rc_file"
    done

    # ── Smart Zsh detection & hooking ──
    if command -v zsh >/dev/null 2>&1 || [ -f "$HOME/.zshrc" ]; then
        local zsh_target=""
        if [ -f "$HOME/.zshrc" ]; then
            zsh_target="$HOME/.zshrc"
        elif [ -f "$PREFIX/etc/zshrc" ]; then
            zsh_target="$PREFIX/etc/zshrc"
        elif command -v zsh >/dev/null 2>&1; then
            zsh_target="$HOME/.zshrc"
        fi

        if [ -n "$zsh_target" ]; then
            [ ! -f "$zsh_target" ] && touch "$zsh_target" 2>/dev/null
            sed -i '/# TMUX-PRO HOOK START/,/# TMUX-PRO HOOK END/d' "$zsh_target" 2>/dev/null
            {
                echo "# TMUX-PRO HOOK START"
                echo "[ -f \"$BANNER_CONFIG\" ] && source \"$BANNER_CONFIG\""
                echo "# TMUX-PRO HOOK END"
            } >> "$zsh_target"
        fi
    fi

    print_success "Banner '$BANNER_NAME' installed successfully!"
    return 0
}

# ==========================================
# 🖥️ HEADER (Full ASCII + Status Bar)
# ==========================================
show_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "   ████████╗███╗   ███╗██╗   ██╗██╗  ██╗    ██████╗ ██████╗  ██████╗"
    echo "   ╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝    ██╔══██╗██╔══██╗██╔═══██╗"
    echo "      ██║   ██╔████╔██║██║   ██║ ╚███╔╝     ██████╔╝██████╔╝██║   ██║"
    echo "      ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗     ██╔═══╝ ██╔══██╗██║   ██║"
    echo "      ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗    ██║     ██║  ██║╚██████╔╝"
    echo "      ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝"
    echo -e "${RESET}"
    echo -e "${PINK}${BOLD}  ◤ SYS.STATUS ◢ ${GREEN}● ONLINE${RESET}   ${PINK}${BOLD}◤ VER ◢ ${CYAN}v4.0${RESET}   ${PINK}${BOLD}◤ BY ◢ ${ORANGE}Art ${WHITE}& ${PINK}MarMu${RESET}"
    echo ""
}

# ==========================================
# 🖥️ MAIN MENU (Pure D — Slanted Frame)
# ==========================================
show_menu() {
    show_header

    # ── BANNER ARSENAL ──
    echo -e "${ORANGE}${BOLD}  ╱▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔╲${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}  ${CYAN}${BOLD}⟨ BANNER ARSENAL ⟩${RESET}                                             ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  ├──────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}                                                                  ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 01${RESET}  ${CYAN}👽  Alien${RESET}              ${WHITE}▸ Extraterrestrial${RESET}     ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 02${RESET}  ${CYAN}💀  Hacker${RESET}             ${WHITE}▸ Terminal Override${RESET}    ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 03${RESET}  ${CYAN}📡  Cyber Matrix${RESET}       ${WHITE}▸ Digital Rain${RESET}         ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 04${RESET}  ${CYAN}🐺  Wolf${RESET}               ${WHITE}▸ Lone Predator${RESET}        ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 05${RESET}  ${CYAN}🕷️   Spider${RESET}             ${WHITE}▸ Web Weaver${RESET}           ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 06${RESET}  ${CYAN}🦇  Bat${RESET}                ${WHITE}▸ Night Shadow${RESET}         ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 07${RESET}  ${CYAN}🦞  Lobster${RESET}            ${WHITE}▸ Deep Claw${RESET}            ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 08${RESET}  ${CYAN}💀  Matrix Skull${RESET}       ${WHITE}▸ Neon Reaper${RESET}          ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 09${RESET}  ${CYAN}🐉  Cyber Dragon${RESET}       ${WHITE}▸ Chrome Wyrm${RESET}          ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}   ${GREEN}${BOLD}⟩⟩ 10${RESET}  ${CYAN}✒️   Name / System${RESET}      ${WHITE}▸ Personal Sigil${RESET}       ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  │${RESET}                                                                  ${ORANGE}${BOLD}│${RESET}"
    echo -e "${ORANGE}${BOLD}  ╲▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁╱${RESET}"
    echo ""

    # ── CUSTOMIZATION ──
    echo -e "${YELLOW}${BOLD}  ╱▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔╲${RESET}"
    echo -e "${YELLOW}${BOLD}  │${RESET}  ${CYAN}${BOLD}⟨ CUSTOMIZATION ⟩${RESET}                                             ${YELLOW}${BOLD}│${RESET}"
    echo -e "${YELLOW}${BOLD}  ├──────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${YELLOW}${BOLD}  │${RESET}                                                                  ${YELLOW}${BOLD}│${RESET}"
    echo -e "${YELLOW}${BOLD}  │${RESET}   ${MAGENTA}${BOLD}⟩⟩ 11${RESET}  ${MAGENTA}🎨  Prompt Design${RESET}     ${WHITE}▸ Arrow Styles${RESET}         ${YELLOW}${BOLD}│${RESET}"
    echo -e "${YELLOW}${BOLD}  │${RESET}   ${MAGENTA}${BOLD}⟩⟩ 12${RESET}  ${MAGENTA}🖌️   Terminal Theme${RESET}    ${WHITE}▸ Color Schemes${RESET}        ${YELLOW}${BOLD}│${RESET}"
    echo -e "${YELLOW}${BOLD}  │${RESET}                                                                  ${YELLOW}${BOLD}│${RESET}"
    echo -e "${YELLOW}${BOLD}  ╲▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁╱${RESET}"
    echo ""

    # ── DANGER ZONE ──
    echo -e "${RED}${BOLD}  ╱▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔╲${RESET}"
    echo -e "${RED}${BOLD}  │${RESET}  ${ORANGE}${BOLD}⟨ DANGER ZONE ⟩${RESET}                                               ${RED}${BOLD}│${RESET}"
    echo -e "${RED}${BOLD}  ├──────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${RED}${BOLD}  │${RESET}                                                                  ${RED}${BOLD}│${RESET}"
    echo -e "${RED}${BOLD}  │${RESET}   ${ORANGE}${BOLD}⟩⟩ 13${RESET}  ${ORANGE}🔄  Restore Original${RESET}  ${WHITE}▸ Revert Changes${RESET}        ${RED}${BOLD}│${RESET}"
    echo -e "${RED}${BOLD}  │${RESET}   ${ORANGE}${BOLD}⟩⟩ 00${RESET}  ${RED}❌  Exit${RESET}              ${WHITE}▸ Terminate${RESET}            ${RED}${BOLD}│${RESET}"
    echo -e "${RED}${BOLD}  │${RESET}                                                                  ${RED}${BOLD}│${RESET}"
    echo -e "${RED}${BOLD}  ╲▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁╱${RESET}"
    echo ""

    # ── Input Prompt ──
    echo -ne "${ORANGE}${BOLD}  ╭─[${CYAN}root@tmux-pro${ORANGE}]─[${PINK}~${ORANGE}]${RESET}\n${ORANGE}${BOLD}  ╰──► ${RESET}"
}

# ==========================================
# 🔁 MAIN LOOP
# ==========================================
while true; do
    show_menu
    IFS= read -r choice

    case "$choice" in
        1|01)
            if apply_banner "Alien" "alien.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        2|02)
            if apply_banner "Hacker" "hacker.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        3|03)
            if apply_banner "Cyber Matrix" "cyber.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        4|04)
            if apply_banner "Wolf" "wolf.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        5|05)
            if apply_banner "Spider" "spider.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        6|06)
            if apply_banner "Bat" "bat.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        7|07)
            if apply_banner "Lobster" "lobster.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        8|08)
            if apply_banner "Matrix Skull" "matrix-skull.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        9|09)
            if apply_banner "Cyber Dragon" "cyber-dragon.sh"; then
                ask_arrow_design; ask_theme
                echo ""
                print_success "Setup complete! Restart your shell to see changes."
                sleep 2
            fi
            ;;
        10)
            echo ""
            print_info "Enter your custom display name:"
            IFS= read -r -p "  👉 Name: " banner_name
            if [ -n "$banner_name" ]; then
                printf '%s\n' "$banner_name" > "$HOME/.banner-name"
                if apply_banner "Name/System" "name.sh"; then
                    ask_arrow_design; ask_theme
                    echo ""
                    print_success "Setup complete! Restart your shell to see changes."
                    sleep 2
                fi
            else
                print_error "Name cannot be empty!"
                sleep 1
            fi
            ;;
        11)
            if [ -f "$DIR/banner-logo/arrow-design.sh" ]; then
                bash "$DIR/banner-logo/arrow-design.sh"
            else
                print_error "arrow-design.sh not found"
                sleep 1
            fi
            ;;
        12)
            if [ -f "$DIR/banner-logo/theme.sh" ]; then
                bash "$DIR/banner-logo/theme.sh"
            else
                print_error "theme.sh not found"
                sleep 1
            fi
            ;;
        13)
            if [ -f "$DIR/banner-logo/restore-original.sh" ]; then
                show_loading "Restoring original settings"
                bash "$DIR/banner-logo/restore-original.sh"
            else
                print_error "restore-original.sh not found"
                sleep 2
            fi
            ;;
        0|00)
            print_success "Exiting... Happy Coding!"
            exit 0
            ;;
        *)
            print_warning "Invalid option! Choose 0-13"
            sleep 1
            continue
            ;;
    esac
done
