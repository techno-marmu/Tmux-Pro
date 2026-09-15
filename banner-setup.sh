#!/data/data/com.termux/files/usr/bin/bash
# 📂 SECTION: Banner-Pro Setup (Beginner Friendly Version)
# 🔍 WHY: ဒီ script က path တွေကို variable ထဲမှာ သိမ်းမထားဘဲ တိုက်ရိုက်ရေးထားတာပါ။
#         Beginner တစ်ယောက် ဖတ်လို့ရအောင်၊ "~/.current-banner.sh ဆိုတာ ဒီနေရာမှာရှိတယ်"
#         ဆိုတာကို တိုက်ရိုက်မြင်ရအောင် ရည်ရွယ်ထားတာပါ။
# 📌 VERSION: Termux (bash + zsh both supported)

# 📂 SECTION: Termux စစ်ဆေးခြင်း
# 🔍 WHY: ဒီ script ကို Termux အပြင် လုပ်ရင် error တွေဖြစ်နိုင်လို့ အရင်စစ်တာပါ
if [ -z "$PREFIX" ]; then
    echo "❌ ဒီ script ကို Termux ထဲမှာပဲ run ပါ။ Termux app မဟုတ်ရင် အလုပ်မဖြစ်ပါ။"
    exit 1
fi

echo "=============================================="
echo "        Banner-Pro  •  Termux Setup"
echo "=============================================="
echo ""

# 📂 SECTION: လိုအပ်တဲ့ package များ install လုပ်ခြင်း
# 🔍 WHY: figlet, toilet, lolcat စတာတွေမရှိရင် banner effect တွေ အလုပ်မလုပ်ဘူး
if [ -f ~/Banner-Pro/requirements.sh ]; then
    echo "🔧 လိုအပ်တဲ့ package များ install လုပ်နေပါတယ်..."
    bash ~/Banner-Pro/requirements.sh
else
    echo "⚠️  ~/Banner-Pro/requirements.sh ကို ရှာမတွေ့ပါ။ ကျော်သွားပါမယ်။"
fi

echo ""

# 📂 SECTION: Script တွေကို run နိုင်အောင် ခွင့်ပြုချက်ပေးခြင်း
# 🔍 WHY: git clone လုပ်ပြီး ရလာတဲ့ .sh file တွေမှာ "run ခွင့်" ပါမလာတတ်ဘူး
echo "🔧 Script file တွေကို run ခွင့်ပေးနေပါတယ်..."
chmod +x ~/Banner-Pro/banner-setup.sh
chmod +x ~/Banner-Pro/requirements.sh
chmod +x ~/Banner-Pro/effect.sh
chmod +x ~/Banner-Pro/banner-logo/restore-original.sh
chmod +x ~/Banner-Pro/banner-logo/cyber.sh
chmod +x ~/Banner-Pro/banner-logo/name.sh

echo "✅ ခွင့်ပြုချက်ပေးပြီးပါပြီ။"
echo ""

# 📂 SECTION: Banner ရွေးချယ်ခြင်း (Menu)
# 🔍 WHY: User ကိုယ်တိုင် banner ဘယ်ဟာသုံးချင်လဲ ရွေးခိုင်းတာပါ။
#         if/elif/else ကို beginner တွေ နားလည်လွယ်အောင် တိုက်ရိုက်ရေးထားတယ်။
echo "မင်းကြိုက်တဲ့ Banner ကို ရွေးပါ 👇"
echo ""
echo "  1) Cyber Banner   → Live sci-fi HUD (နာရီ၊ digits၊ tone effect)"
echo "  2) Name Banner    → မင်းနာမည်ကို figlet/toilet art နဲ့ ပြမယ်"
echo "  3) Alien          → alien.txt ASCII art"
echo "  4) Hacker         → hacker.txt ASCII art"
echo "  5) Cyber Dragon   → cyber-dragon.txt ASCII art"
echo "  6) Wolf           → wolf.txt ASCII art"
echo "  7) Matrix Skull   → matrix-skull.txt ASCII art"
echo "  8) Spider         → spider.txt ASCII art"
echo "  9) Bat            → bat.txt ASCII art"
echo " 10) Lobster        → lobster.txt ASCII art"
echo " 11) ကျော်မယ် (Skip)"
echo ""
read -p "ရွေးချယ်ပါ [1-11]: " CHOICE

echo ""

# 📂 SECTION: User ရွေးလိုက်တဲ့အတိုင်း ~/.current-banner.sh ထဲကို ရေးထည့်ခြင်း
# 🔍 WHY: "> ~/.current-banner.sh" ဆိုတာ ဟောင်းတာကို overwrite လုပ်ပြီး အသစ်ရေးတာပါ။
#         ဒီ file ထဲမှာ command တစ်ကြောင်းပဲ ရှိမှာမို့ .bashrc/.zshrc ထဲက
#         "source ~/.current-banner.sh" တစ်ကြောင်းက ဒီကို ခေါ်သုံးမှာပါ။
if [ "$CHOICE" = "1" ]; then
    echo "bash ~/Banner-Pro/banner-logo/cyber.sh" > ~/.current-banner.sh
    echo "✅ Cyber Banner ကို default အနေနဲ့ သတ်မှတ်လိုက်ပါပြီ။"

elif [ "$CHOICE" = "2" ]; then
    echo "bash ~/Banner-Pro/banner-logo/name.sh" > ~/.current-banner.sh
    echo "✅ Name Banner ကို default အနေနဲ့ သတ်မှတ်လိုက်ပါပြီ။"

elif [ "$CHOICE" = "3" ]; then
    echo "cat ~/Banner-Pro/banner-logo/images/alien.txt | lolcat" > ~/.current-banner.sh
    echo "✅ Alien Banner ကို default အနေနဲ့ သတ်မှတ်လိုက်ပါပြီ။"

elif [ "$CHOICE" = "4" ]; then
    echo "cat ~/Banner-Pro/banner-logo/images/hacker.txt | lolcat" > ~/.current-banner.sh
    echo "✅ Hacker Banner ကို default အနေနဲ့ သတ်မှတ်လိုက်ပါပြီ။"

elif [ "$CHOICE" = "5" ]; then
    echo "cat ~/Banner-Pro/banner-logo/images/cyber-dragon.txt | lolcat" > ~/.current-banner.sh
    echo "✅ Cyber Dragon Banner ကို default အနေနဲ့ သတ်မှတ်လိုက်ပါပြီ။"

elif [ "$CHOICE" = "6" ]; then
    echo "cat ~/Banner-Pro/banner-logo/images/wolf.txt | lolcat" > ~/.current-banner.sh
    echo "✅ Wolf Banner ကို default အနေနဲ့ သတ်မှတ်လိုက်ပါပြီ။"

elif [ "$CHOICE" = "7" ]; then
    echo "cat ~/Banner-Pro/banner-logo/images/matrix-skull.txt | lolcat" > ~/.current-banner.sh
    echo "✅ Matrix Skull Banner ကို default အနေနဲ့ သတ်မှတ်လိုက်ပါပြီ။"

elif [ "$CHOICE" = "8" ]; then
    echo "cat ~/Banner-Pro/banner-logo/images/spider.txt | lolcat" > ~/.current-banner.sh
    echo "✅ Spider Banner ကို default အနေနဲ့ သတ်မှတ်လိုက်ပါပြီ။"

elif [ "$CHOICE" = "9" ]; then
    echo "cat ~/Banner-Pro/banner-logo/images/bat.txt | lolcat" > ~/.current-banner.sh
    echo "✅ Bat Banner ကို default အနေနဲ့ သတ်မှတ်လိုက်ပါပြီ။"

elif [ "$CHOICE" = "10" ]; then
    echo "cat ~/Banner-Pro/banner-logo/images/lobster.txt | lolcat" > ~/.current-banner.sh
    echo "✅ Lobster Banner ကို default အနေနဲ့ သတ်မှတ်လိုက်ပါပြီ။"

else
    echo "⏭️  Banner ရွေးချယ်ခြင်း ကျော်လိုက်ပါပြီ။"
    echo "နောက်မှ ~/Banner-Pro/banner-setup.sh ကို ထပ် run ပြီး ရွေးလို့ရပါတယ်။"
fi

echo ""

# 📂 SECTION: .bashrc / .zshrc ထဲကို source line ထည့်ခြင်း
# 🔍 WHY: Terminal အသစ်ဖွင့်တိုင်း banner auto ပေါ်အောင်, .bashrc (bash) နဲ့
#         .zshrc (zsh) နှစ်ခုစလုံးထဲမှာ "source ~/.current-banner.sh" ဆိုတဲ့
#         command တစ်ကြောင်းတည်းကိုသာ >> နဲ့ (ရှိပြီးသားတွေကို မဖျက်ဘဲ) ထပ်ထည့်တာပါ။
#         Line ထပ်ခါထပ်ခါ မထည့်မိအောင် grep နဲ့ အရင်စစ်တယ်။

if [ "$CHOICE" != "11" ]; then

    # ---- .bashrc အတွက် ----
    if [ -f ~/.bashrc ]; then
        if grep -q "source ~/.current-banner.sh" ~/.bashrc; then
            echo "ℹ️  .bashrc ထဲမှာ Banner-Pro line ရှိပြီးသားပါ။ ထပ်မထည့်တော့ပါ။"
        else
            echo "source ~/.current-banner.sh" >> ~/.bashrc
            echo "✅ ~/.bashrc ထဲကို banner line ထည့်ပြီးပါပြီ။"
        fi
    else
        echo "source ~/.current-banner.sh" > ~/.bashrc
        echo "✅ ~/.bashrc အသစ်ဆောက်ပြီး banner line ထည့်ပြီးပါပြီ။"
    fi

    # ---- .zshrc အတွက် (zsh သုံးသူများအတွက်လည်း အလုပ်လုပ်ရန်) ----
    if [ -f ~/.zshrc ]; then
        if grep -q "source ~/.current-banner.sh" ~/.zshrc; then
            echo "ℹ️  .zshrc ထဲမှာ Banner-Pro line ရှိပြီးသားပါ။ ထပ်မထည့်တော့ပါ။"
        else
            echo "source ~/.current-banner.sh" >> ~/.zshrc
            echo "✅ ~/.zshrc ထဲကို banner line ထည့်ပြီးပါပြီ။"
        fi
    fi
    # ⚠️ .zshrc မရှိရင် zsh မသုံးဘူးလို့ ယူဆပြီး file အသစ်ဆောက်မပေးပါ။
    #    (zsh install လုပ်ရင် ~/.zshrc auto ဖြစ်လာတတ်လို့)

fi

echo ""
echo "=============================================="
echo "✅ Setup ပြီးပါပြီ!"
echo "Terminal အသစ်ပြန်ဖွင့် (သို့) 'source ~/.bashrc' run ပြီး Banner ကို ကြည့်ပါ။"
echo ""
echo "Banner ပြန်ဖျက်ချင်ရင် ~/Banner-Pro/banner-logo/restore-original.sh ကို run ပါ။"
echo "=============================================="
