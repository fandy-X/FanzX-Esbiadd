#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#   FANZX SOLO v3 — Auto Installer untuk Termux
#   Jalankan: bash install.sh
# ============================================================

R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'
C='\033[1;36m'; W='\033[1;37m'; D='\033[0m'
B='\033[1;34m'; M='\033[1;35m'

ok()  { echo -e "  ${G}✓${D}  $1"; }
err() { echo -e "  ${R}✗${D}  $1"; }
inf() { echo -e "  ${C}·${D}  $1"; }
hdr() { echo -e "\n${Y}  ── $1 ──${D}"; }
skip(){ echo -e "  ${B}↷${D}  $1 [sudah ada]"; }

clear
echo -e "${C}"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "    F A N Z X   S O L O   v3  —  Installer"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${D}"

# ── Cek Termux ───────────────────────────────────────────────
if [ ! -d "/data/data/com.termux" ]; then
    err "Script ini hanya untuk Termux di Android!"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="/data/data/com.termux/files/usr"
DRIVER_PATH="$PREFIX/bin/chromedriver"
CHROME_PATH="$PREFIX/bin/chromium"

# ── 1. Update repo ───────────────────────────────────────────
hdr "Update package list"
inf "Mengupdate repo Termux..."
pkg update -y -q 2>/dev/null && ok "Repo updated" || err "Update gagal (lanjut...)"

# ── 2. Enable x11-repo (diperlukan untuk paket X11) ──────────
hdr "Enable X11 repo"
if pkg list-installed 2>/dev/null | grep -q "^x11-repo"; then
    skip "x11-repo"
else
    inf "Mengaktifkan x11-repo..."
    pkg install -y x11-repo -q 2>/dev/null \
        && ok "x11-repo aktif" \
        || err "x11-repo gagal — beberapa paket X11 mungkin tidak tersedia"
fi

# ── 3. Package Termux ────────────────────────────────────────
hdr "Install package Termux"

PKG_LIST=(
    "python"            # Python 3
    "chromium"          # Browser + chromedriver untuk Selenium
    "xorg-xhost"        # xhost — izin akses X server untuk Chromium
    "xdpyinfo"          # Deteksi DISPLAY yang aktif
    "xorg-xauth"        # Xauthority — auth X11 session
)

for pkg in "${PKG_LIST[@]}"; do
    if pkg list-installed 2>/dev/null | grep -q "^${pkg}"; then
        skip "$pkg"
    else
        inf "Menginstall $pkg..."
        if pkg install -y "$pkg" -q 2>/dev/null; then
            ok "$pkg"
        else
            err "$pkg gagal — coba manual: pkg install $pkg"
        fi
    fi
done

# ── 4. Update pip ────────────────────────────────────────────
hdr "Update pip"
inf "Mengupdate pip..."
python -m pip install --upgrade pip --break-system-packages -q 2>/dev/null \
    && ok "pip up-to-date" || inf "pip sudah terbaru"

# ── 5. Library Python ────────────────────────────────────────
hdr "Install library Python"

PIP_LIST=(
    "rich"              # UI terminal — panel, progress bar, tabel
    "selenium"          # Otomasi browser Chromium
    "cryptography"      # AES enkripsi — untuk baca file terenkripsi
)

for lib in "${PIP_LIST[@]}"; do
    # Cek apakah sudah terinstall
    if python -c "import ${lib%%[^a-zA-Z0-9_]*}" 2>/dev/null; then
        skip "$lib"
    else
        inf "pip install $lib..."
        if python -m pip install "$lib" --break-system-packages -q 2>/dev/null; then
            ok "$lib"
        else
            err "$lib gagal — coba manual: pip install $lib --break-system-packages"
        fi
    fi
done

# ── 6. Cek Chromium & ChromeDriver ───────────────────────────
hdr "Cek Chromium & ChromeDriver"

if [ -f "$CHROME_PATH" ]; then
    CV=$(chromium --version 2>/dev/null | head -1)
    ok "chromium : ${CV:-ditemukan}"
else
    err "chromium tidak ditemukan di $CHROME_PATH"
    inf "Coba manual: pkg install chromium"
fi

if [ -f "$DRIVER_PATH" ]; then
    DV=$(chromedriver --version 2>/dev/null | head -1)
    ok "chromedriver : ${DV:-ditemukan}"
else
    err "chromedriver tidak ditemukan!"
    inf "Biasanya otomatis ikut chromium. Coba: pkg install chromium"
fi

# ── 7. Cek Termux:X11 ────────────────────────────────────────
hdr "Cek dukungan X11"

if command -v xhost &>/dev/null; then
    ok "xhost tersedia"
else
    err "xhost tidak ditemukan — install xorg-xhost"
fi

if command -v xdpyinfo &>/dev/null; then
    ok "xdpyinfo tersedia"
else
    err "xdpyinfo tidak ditemukan — install xdpyinfo"
fi

# Cek apakah Termux:X11 app terpasang
if pm list packages 2>/dev/null | grep -q "com.termux.x11"; then
    ok "Termux:X11 app terpasang"
else
    echo -e "\n  ${Y}⚠  Termux:X11 app belum terpasang${D}"
    echo -e "  ${W}   Diperlukan untuk fitur login via browser X11.${D}"
    echo -e "  ${C}   Download di: https://github.com/termux/termux-x11/releases${D}"
fi

# ── 8. Verifikasi import Python ──────────────────────────────
hdr "Verifikasi instalasi Python"

python -c "
libs = [
    ('rich',         'rich'),
    ('selenium',     'selenium'),
    ('cryptography', 'cryptography'),
]
for label, mod in libs:
    try:
        __import__(mod)
        print(f'  \033[1;32m✓\033[0m  {label}')
    except ImportError:
        print(f'  \033[1;31m✗\033[0m  {label}  ← GAGAL, install manual')
"

# ── 9. Info sistem ───────────────────────────────────────────
hdr "Info sistem"
PY_VER=$(python --version 2>&1)
ok "Python  : $PY_VER"
ok "Prefix  : $PREFIX"
ok "Lokasi  : $SCRIPT_DIR"

# ── 10. Cek file tool ────────────────────────────────────────
hdr "Cek file tool"

ENC_FILE="$SCRIPT_DIR/fanzx_enc.py"
KEY_FILE="$SCRIPT_DIR/acc_key.py"

if [ -f "$ENC_FILE" ]; then
    ok "fanzx_enc.py ditemukan — tool siap dijalankan"
    TOOL_READY=1
else
    err "fanzx_enc.py belum ada"
    TOOL_READY=0
fi

if [ -f "$KEY_FILE" ]; then
    ok "acc_key.py ditemukan"
else
    err "acc_key.py tidak ditemukan!"
fi

# ── Selesai ──────────────────────────────────────────────────
echo ""
echo -e "${C}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e "${G}  ✅  Instalasi selesai!${D}"
echo ""

if [ "$TOOL_READY" -eq 1 ]; then
    # Tool sudah ada — langsung kasih tahu cara pakai
    echo -e "  ${W}Cara jalankan tool:${D}"
    echo -e "  ${C}    python fanzx_enc.py${D}"
    echo ""
    echo -e "  ${W}Untuk login via Browser X11, aktifkan dulu:${D}"
    echo -e "  ${Y}    1. Buka app Termux:X11${D}"
    echo -e "  ${Y}    2. Jalankan di terminal: export DISPLAY=:0${D}"
    echo -e "  ${Y}    3. Baru jalankan: python fanzx_enc.py${D}"
else
    # Tool belum ada — minta user kirim HWID dulu
    echo -e "  ${Y}⚠  File tool (fanzx_enc.py) belum ada.${D}"
    echo -e "  ${W}   Langkah selanjutnya:${D}"
    echo ""
    echo -e "  ${C}  1. Jalankan perintah berikut untuk melihat HWID:${D}"
    echo -e "  ${W}       python acc_key.py${D}"
    echo ""
    echo -e "  ${C}  2. Kirim HWID ke developer untuk mendapatkan file tool.${D}"
    echo -e "  ${C}  3. Taruh file fanzx_enc.py di folder yang sama.${D}"
    echo -e "  ${C}  4. Jalankan: python acc_key.py${D}"
    echo -e "  ${C}  5. Ambil HWID dan kirim ke dev${D}"

    echo ""

    # Tanya user apakah mau langsung jalankan acc_key.py sekarang
    echo -e "  ${Y}Mau tampilkan HWID sekarang? [y/n] ${D}\c"
    read -r jawab
    if [[ "$jawab" =~ ^[Yy]$ ]]; then
        echo ""
        if [ -f "$KEY_FILE" ]; then
            python "$KEY_FILE"
        else
            err "acc_key.py tidak ditemukan di $SCRIPT_DIR"
        fi
    fi
fi

echo ""
echo -e "${C}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo ""
