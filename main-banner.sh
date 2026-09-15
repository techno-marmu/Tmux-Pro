#!/data/data/com.termux/files/usr/bin/bash
# Location: $HOME/Banner-Pro/banner-setup.sh

# ==========================================
# 🎨 COLOR VARIABLES
# ==========================================
RESET="\e[0m"
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
MAGENTA="\e[1;35m"
CYAN="\e[1;36m"
WHITE="\e[1;37m"

# ==========================================
# 🛠 HELPER FUNCTIONS (Professional Format)
# ==========================================
print_step() {
    echo -e "${MAGENTA}[*] $1${RESET}"
}

print_success() {
    echo -e "${GREEN}[+] $1${RESET}"
}

print_error() {
    echo -e "${RED}[!] Error: $1${RESET}"
}

print_info() {
    echo -e "${BLUE}[i] $1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}[~] $1${RESET}"
}

# ==========================================
# ⚙️ DIRECTORY & BACKUP LOGIC
# ==========================================
DIR="$HOME/Banner-Pro"
if [ ! -d "$DIR" ]; then
    print_error "Directory not found."
    print_info "Please run from: cd $HOME/Banner-Pro"
    exit 1
fi

MOTD="$PREFIX/etc/motd"
BANNER_CONFIG="$HOME/.termux_banner.sh"

backup_files() {
    print_step "Checking and creating backups for all shells..."

    # bash.bashrc Backup  
    if [ -f "$PREFIX/etc/bash.bashrc" ] && [ ! -f "$PREFIX/etc/bash.bashrc.bak" ]; then  
        cp "$PREFIX/etc/bash.bashrc" "$PREFIX/etc/bash.bashrc.bak"  
        print_success "Backed up system bashrc"  
    fi  
    # zshrc Backup
    if [ -f "$PREFIX/etc/zshrc" ] && [ ! -f "$PREFIX/etc/zshrc.bak" ]; then
        cp "$PREFIX/etc/zshrc" "$PREFIX/etc/zshrc.bak"
        print_success "Backed up system zshrc"
    fi

    # .bashrc Backup  
    if [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.bashrc.bak" ]; then  
        cp -p "$HOME/.bashrc" "$HOME/.bashrc.bak"  
        print_success "Backed up {~/bashrc} completef"  
    fi  
    # .zshrc Backup  
    if [ -f "$HOME/.zshrc" ] && [ ! -f "$HOME/.zshrc.bak" ]; then  
        cp -p "$HOME/.zshrc" "$HOME/.zshrc.bak"  
        print_success "Backed up {~/zshrc} completed"  
    fi  


    # MOTD Backup (Typo fixed)
    if [ ! -f "$MOTD.bak" ] && [ -f "$MOTD" ]; then  
        cp -p "$MOTD" "$MOTD.bak"  
        print_success "Backed up motd"  
    fi
        echo
        cd $HOME
        print_success "Already Done! Completed Backup files" 
}

# ==========================================
# 🎨 APPLY THEME FUNCTION (Dracula Vibrant)
# ==========================================
apply_theme() {
    print_step "Applying Vibrant Dark Theme..."

    mkdir -p "$HOME/.termux"  
      
    cat <<EOF > "$HOME/.termux/colors.properties"
# Dracula Vibrant Dark Theme
background=#282A36
foreground=#F8F8F2
cursor=#F8F8F2
color0=#21222C
color8=#6272A4
color1=#FF5555
color9=#FF6E6E
color2=#50FA7B
color10=#69FF94
color3=#F1FA8C
color11=#FFFFA5
color4=#BD93F9
color12=#D6ACFF
color5=#FF79C6
color13=#FF92DF
color6=#8BE9FD
color14=#A4FFFF
color7=#F8F8F2
color15=#FFFFFF
EOF

    termux-reload-settings  
    print_success "Terminal color theme updated successfully!"
}

# ==========================================
# 🍁 APPLY BANNER & CROSS-SHELL PROMPT
# ==========================================
apply_banner() {
    local BANNER_FILE=$1
    local IS_SCRIPT=$2

    backup_files    
    
    # Clear MOTD safely
    if [ -f "$MOTD" ]; then
        : > "$MOTD"
    else
        touch "$MOTD"
    fi

    print_step "Generating cross-shell configuration..."  
      
    # ဖိုင်တစ်ဖိုင်တည်းမှာ Bash ရော Zsh ပါ အလုပ်လုပ်မည့် Code များ ရေးသွင်းခြင်း  
    echo "#!/bin/bash" > "$BANNER_CONFIG"  
    echo "clear" >> "$BANNER_CONFIG"  
      
    if [ "$IS_SCRIPT" == "true" ]; then  
        echo "bash $DIR/banner-logo/$BANNER_FILE" >> "$BANNER_CONFIG"  
    else  
        echo "cat $DIR/banner-logo/images/$BANNER_FILE | lolcat" >> "$BANNER_CONFIG"  
    fi  

    echo "alias matrix='cmatrix -b -s -C cyan'" >> "$BANNER_CONFIG"  

    # Auto-detect Zsh vs Bash ဖြင့် မြှားဒီဇိုင်း (Prompt) ပြောင်းပေးမည့်စနစ်  
    cat << 'EOF' >> "$BANNER_CONFIG"

# ==========================================
# Banner-Pro Cross Shell Prompt
# ==========================================

if [ -n "${ZSH_VERSION:-}" ]; then
    autoload -U colors 2>/dev/null
    colors 2>/dev/null
    PROMPT=$'%F{cyan}\n┌──[%F{green}%n%F{cyan}]──[%F{blue}%~%F{cyan}]\n└──► %f'
elif [ -n "${BASH_VERSION:-}" ]; then
    PS1='\n\[\e[1;36m\]┌──[\[\e[1;32m\]\u\[\e[1;36m\]]──[\[\e[1;34m\]\w\[\e[1;36m\]]\n└──► \[\e[0m\]'
fi
EOF

    chmod +x "$BANNER_CONFIG"  

    print_step "Hooking banner into Bash and Zsh..."  
      
    # Shell Config ဖိုင် (၃) မျိုးလုံးကို Loop ပတ်ပြီး Hook လုပ်ခြင်း  
    for rc_file in "$PREFIX/etc/bash.bashrc" "$HOME/.bashrc" "$HOME/.zshrc"; do  
        # ဖိုင်မရှိသေးရင် အသစ်တည်ဆောက်မည်  
        if [ ! -f "$rc_file" ]; then  
            touch "$rc_file"  
        fi  
          
        # အဟောင်းရှိရင် ရှင်းမည် (Safe Hooking Fix)
        sed -i '/# BANNER-PRO HOOK START/,/# BANNER-PRO HOOK END/d' "$rc_file" 2>/dev/null  
        sed -i '/# BANNER-PRO START/,/# BANNER-PRO END/d' "$rc_file" 2>/dev/null  
          
        # Source Command သွားထည့်မည်  
        echo "# BANNER-PRO HOOK START" >> "$rc_file"  
        echo "if [ -f \"$BANNER_CONFIG\" ]; then source \"$BANNER_CONFIG\"; fi" >> "$rc_file"  
        echo "# BANNER-PRO HOOK END" >> "$rc_file"
    done  

    print_success "Banner & Terminal Prompt configured for Bash and Zsh."  

    echo ""  
    print_info "Do you want to apply the Vibrant Dark Terminal Theme?"  
    read -p "  👉 Choose (Y/N): " choose  

    if [[ "$choose" == "Y" || "$choose" == "y" || "$choose" == "Yes" || "$choose" == "yes" ]]; then  
        echo ""  
        apply_theme  
    else  
        echo ""  
        print_info "Skipped terminal theme. Keeping current colors."  
    fi  

    echo ""  
    print_success "Setup is 100% Complete! Restart your Termux to see changes."  
    sleep 3
}

# ==========================================
# 🖥 MAIN MENU
# ==========================================
while true; do
    clear
    echo -e "${CYAN}=========================================${RESET}"
    echo -e "${GREEN}      BANNER-PRO SETUP MENU (CROSS-SHELL)${RESET}"
    echo -e "${CYAN}=========================================${RESET}"
    echo -e "${WHITE}  [1]${RESET} Alien Banner"
    echo -e "${WHITE}  [2]${RESET} Hacker Banner"
    echo -e "${WHITE}  [3]${RESET} Spider 🕸️ 🕷️ Banner"
    echo -e "${WHITE}  [4]${RESET} Cyber Matrix 📡"
    echo -e "${WHITE}  [5]${RESET} Restore Original Termux"
    echo -e "${WHITE}  [6]${RESET} Exit"
    echo -e "${CYAN}=========================================${RESET}"
    read -p "Select an option (1-6): " opt

    case $opt in  
        1) apply_banner "Alien.txt" "false" ;;  
        2) apply_banner "Hacker.txt" "false" ;;  
        3) apply_banner "Spider.txt" "false" ;;  
        4) apply_banner "cyber.sh" "true" ;;  
        5)   
           print_step "Restoring original settings..."  
           bash "$DIR/banner-logo/restore-original.sh"  
           sleep 2  
           ;;  
        6)   
           print_success "Exiting... Happy Coding!"  
           exit 0   
           ;;  
        *)   
           print_warning "Invalid Option. Try again."  
           sleep 1  
           ;;  
    esac
done
