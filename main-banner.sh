#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Project: Banner-Pro Setup Tool
# Location: $SCRIPT_DIR/main-setup.sh
# Version: 4.0 (Hybrid Final Edition — v3.2 Preview + v3.4 Architecture)
# Description: Automated setup script for Termux banner customization,
#              interactive preview, dynamic path resolution, custom name banner,
#              smart cross-shell configuration, prompt arrows & themes.
# Platform: Termux Environment Only
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
# 🛠 HELPER FUNCTIONS (POSIX Portable printf)
# ==========================================
print_step()    { printf "${MAGENTA}[*]${RESET} %s\n" "$1"; }
print_success() { printf "${GREEN}[+]${RESET} %s\n" "$1"; }
print_error()   { printf "${RED}[!] Error:${RESET} %s\n" "$1"; }
print_info()    { printf "${BLUE}[i]${RESET} %s\n" "$1"; }
print_warning() { printf "${YELLOW}[~]${RESET} %s\n" "$1"; }

# ==========================================
# 📁 DYNAMIC PATH RESOLUTION (v3.4 Feature)
# ==========================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
DIR="$SCRIPT_DIR"

# ==========================================
# ⚙️ ENVIRONMENT & DIRECTORY CHECK
# ==========================================
if [ -z "${PREFIX:-}" ]; then
    print_error "This script must be executed inside Termux environment."
    exit 1
fi

if [ ! -d "$DIR" ]; then
    print_error "Directory '$DIR' not found."
    print_info "Please execute from the repository directory: cd \$HOME/Banner-Pro"
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
BANNER_CONFIG="$HOME/.termux_banner.sh"

# ==========================================
# 💾 BACKUP LOGIC
# ==========================================
backup_files() {
    show_loading "Creating system backups"

    [ -f "$PREFIX/etc/bash.bashrc" ] && [ ! -f "$PREFIX/etc/bash.bashrc.bak" ] && cp -p "$PREFIX/etc/bash.bashrc" "$PREFIX/etc/bash.bashrc.bak"
    [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.bashrc.bak" ] && cp -p "$HOME/.bashrc" "$HOME/.bashrc.bak"
    [ -f "$HOME/.zshrc" ] && [ ! -f "$HOME/.zshrc.bak" ] && cp -p "$HOME/.zshrc" "$HOME/.zshrc.bak"
    [ -f "$MOTD" ] && [ ! -f "$MOTD.bak" ] && cp -p "$MOTD" "$MOTD.bak"
}

# ==========================================
# 🎨 HELPER: PROMPT DESIGN SELECTION
# ==========================================
ask_arrow_design() {
    echo ""
    print_info "Do you want to change the Prompt Design (Arrow Styles)?"
    read -p "  👉 Choose (Y/N): " prompt_choose

    if [[ "$prompt_choose" =~ ^[Yy]([Ee][Ss])?$ ]]; then
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
# 🖌️ HELPER: TERMINAL THEME SELECTION
# ==========================================
ask_theme() {
    echo ""
    print_info "Do you want to change the Terminal Theme?"
    read -p "  👉 Choose (Y/N): " choose

    if [[ "$choose" =~ ^[Yy]([Ee][Ss])?$ ]]; then
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
# 🚀 APPLY BANNER LOGIC (PREVIEW + MULTI-PATH)
# ==========================================
apply_banner() {
    local BANNER_NAME="$1"
    local BANNER_FILE="$2"
    local TARGET_PATH=""

    # ── Multi-path fallback ( Arts/ -> banner-logo/ -> Root ) ──
    if [ -f "$DIR/banner-logo/Arts/$BANNER_FILE" ]; then
        TARGET_PATH="$DIR/banner-logo/Arts/$BANNER_FILE"
    elif [ -f "$DIR/banner-logo/$BANNER_FILE" ]; then
        TARGET_PATH="$DIR/banner-logo/$BANNER_FILE"
    elif [ -f "$DIR/$BANNER_FILE" ]; then
        TARGET_PATH="$DIR/$BANNER_FILE"
    fi

    # Name/System banner မဟုတ်ပါက File ရှိမရှိ စစ်ဆေးခြင်း
    if [ -z "$TARGET_PATH" ] && [ "$BANNER_FILE" != "name.sh" ]; then
        print_error "Banner file '$BANNER_FILE' not found in repository!"
        sleep 2
        return 1
    fi

    # ==========================================
    # 👁️ INTERACTIVE PREVIEW LOGIC (v3.2 Base)
    # ==========================================
    clear
    echo -e "${CYAN}=========================================${RESET}"
    echo -e "${GREEN}         BANNER PREVIEW: ${BANNER_NAME}    ${RESET}"
    echo -e "${CYAN}=========================================${RESET}\n"

    if [ "$BANNER_FILE" == "name.sh" ]; then
        # Custom Name Banner အတွက် Preview ပြခြင်း
        if [ -f "$HOME/.banner-name" ]; then
            NAME=$(cat "$HOME/.banner-name")
            if command -v figlet >/dev/null 2>&1; then
                if command -v lolcat >/dev/null 2>&1; then
                    figlet -f slant "$NAME" | lolcat
                else
                    figlet -f slant "$NAME"
                fi
            else
                echo "═══ $NAME ═══"
            fi
        fi
    else
        # Standard Banner File များအတွက် Preview ပြခြင်း
        bash "$TARGET_PATH"
    fi

    echo -e "\n${CYAN}=========================================${RESET}"
    print_info "Do you want to apply this banner?"
    read -p "  👉 Choose (Y/N): " confirm_apply

    # Apply မလုပ်ပါက Menu သို့ ပြန်ထွက်မည်
    if [[ ! "$confirm_apply" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        print_warning "Cancelled! Returning to menu..."
        sleep 1.5
        return 0
    fi

    # ==========================================
    # 🚀 ACTUAL APPLY LOGIC
    # ==========================================
    backup_files

    # Clear MOTD Welcome Message
    if [ -f "$MOTD" ]; then : > "$MOTD"; else touch "$MOTD" 2>/dev/null; fi

    show_loading "Generating cross-shell configuration hook"

    # Config File အသစ်ထုတ်ယူခြင်း
    {
        echo "#!/data/data/com.termux/files/usr/bin/bash"
        echo "# Banner-Pro — current banner config (v4.0)"
        echo "clear"

        if [ "$BANNER_FILE" == "name.sh" ]; then
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
        else
            echo "if [ -f \"$TARGET_PATH\" ]; then"
            echo "    bash \"$TARGET_PATH\""
            echo "fi"
        fi

        echo ""
        echo "alias matrix='cmatrix -b -s -C cyan' 2>/dev/null"
    } > "$BANNER_CONFIG"
    chmod +x "$BANNER_CONFIG"

    # ==========================================
    # 🔍 SMART SHELL CHECK & HOOKING
    # ==========================================
    local target_rc_files=("$PREFIX/etc/bash.bashrc" "$HOME/.bashrc")

    if command -v zsh &>/dev/null || [ -f "$HOME/.zshrc" ]; then
        target_rc_files+=("$HOME/.zshrc")
    fi

    for rc_file in "${target_rc_files[@]}"; do
        if [ ! -f "$rc_file" ]; then
            touch "$rc_file" 2>/dev/null
        fi

        # ထပ်နေသော Hook စာကြောင်းဟောင်းများကို Clean လုပ်ခြင်း
        sed -i '/# BANNER-PRO HOOK START/,/# BANNER-PRO HOOK END/d' "$rc_file" 2>/dev/null
        sed -i '/# BANNER-PRO START/,/# BANNER-PRO END/d' "$rc_file" 2>/dev/null

        # Hook စာကြောင်း အသစ်ထည့်ခြင်း
        {
            echo "# BANNER-PRO HOOK START"
            echo "if [ -f \"$BANNER_CONFIG\" ]; then source \"$BANNER_CONFIG\"; fi"
            echo "# BANNER-PRO HOOK END"
        } >> "$rc_file"
    done

    # Customization Helpers များ လှမ်းခေါ်ခြင်း
    ask_arrow_design
    ask_theme

    echo ""
    print_success "Banner '$BANNER_NAME' setup 100% complete! Restart Termux to see changes."
    sleep 2
    return 0
}

# ==========================================
# 🖥️ HEADER (Full ASCII + Status Bar)
# ==========================================
show_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "   ██████╗  █████╗   ███╗   ██╗  ███╗    ██╗███████╗██████╗      ██████╗  ██████╗   ██████╗"
    echo "   ██╔══██╗██╔══██╗████╗  ██║ ████╗   ██║██╔════╝██╔══██╗    ██╔══██╗██ ╔═██╗ ██╔═══██╗"
    echo "   ██████╔╝███████║██╔██╗ ██║ ██╔██╗ ██║█████╗  ██████╔╝    ██████╔╝ ██████╔  ██║     ██║"
    echo "   ██╔══██╗██╔══██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗    ██╔═══╝  ██╔══██╗ ██║     ██║"
    echo "   ██████╔╝██║   ██║██║ ╚████║ ██║ ╚████║███████╗██║   ██║    ██║        ██║    ██║╚██████╔╝"
    echo "   ╚═════╝ ╚═╝   ╚═╝╚═╝  ╚═══╝  ╚═╝  ╚═══╝╚══════╝╚═╝   ╚═╝    ╚═╝        ╚═╝    ╚═╝  ╚═════╝"
    echo -e "${RESET}"
    echo -e "${PINK}${BOLD}  ◤ SYS.STATUS ◢ ${GREEN}● ONLINE${RESET}   ${PINK}${BOLD}◤ VER ◢ ${CYAN}v4.0${RESET}   ${PINK}${BOLD}◤ BY ◢ ${ORANGE}Cyber-Matrix${RESET}"
    echo ""
}

# ==========================================
# 🖥️ MAIN MENU (Slanted Frame Cyberpunk)
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
    echo -ne "${ORANGE}${BOLD}  ╭─[${CYAN}COLLECT MENU NUMBER${ORANGE}]─[${PINK}~${ORANGE}]${RESET}\n${ORANGE}${BOLD}  ╰──► ${RESET}"
}

# ==========================================
# 🔁 MAIN LOOP
# ==========================================
while true; do
    show_menu
    read -r choice

    case "$choice" in
        1|01) apply_banner "Alien" "alien.sh" ;;
        2|02) apply_banner "Hacker" "hacker.sh" ;;
        3|03) apply_banner "Cyber Matrix" "cyber.sh" ;;
        4|04) apply_banner "Wolf" "wolf.sh" ;;
        5|05) apply_banner "Spider" "spider.sh" ;;
        6|06) apply_banner "Bat" "bat.sh" ;;
        7|07) apply_banner "Lobster" "lobster.sh" ;;
        8|08) apply_banner "Matrix Skull" "matrix-skull.sh" ;;
        9|09) apply_banner "Cyber Dragon" "cyber-dragon.sh" ;;
        10)
            echo ""
            print_info "Enter your custom display name:"
            read -p "  👉 Name: " banner_name
            if [ -n "$banner_name" ]; then
                printf '%s\n' "$banner_name" > "$HOME/.banner-name"
                apply_banner "Name/System" "name.sh"
            else
                print_error "Name cannot be empty!"
                sleep 1
            fi
            ;;
        11)
            ask_arrow_design
            sleep 1
            ;;
        12)
            ask_theme
            sleep 1
            ;;
        13)
            show_loading "Restoring original settings"
            if [ -f "$DIR/banner-logo/restore-original.sh" ]; then
                bash "$DIR/banner-logo/restore-original.sh"
            else
                print_error "restore-original.sh not found!"
            fi
            sleep 2
            ;;
        0|00)
            print_success "Exiting... Happy Coding!"
            exit 0
            ;;
        *)
            print_warning "Invalid option! Choose (00-13)"
            sleep 1
            ;;
    esac
done
