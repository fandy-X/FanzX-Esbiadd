#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#   FANZX SOLO v3 — Auto Installer untuk Termux
#   Jalankan: bash install.sh
# ============================================================

# ── Warna ────────────────────────────────────────────────────
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'
C='\033[1;36m'; W='\033[1;37m'; D='\033[0m'

ok()  { echo -e "  ${G}✓${D}  $1"; }
err() { echo -e "  ${R}✗${D}  $1"; }
inf() { echo -e "  ${C}·${D}  $1"; }
hdr() { echo -e "\n${Y}  ── $1 ──${D}"; }

clear
echo -e "${C}"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "    F A N Z X   S O L O   v3  —  Installer"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${D}"

# ── Cek Termux ───────────────────────────────────────────────
if [ ! -d "/data/data/com.termux" ]; then
    err "Script ini hanya untuk Termux di Android!"
    exit 1
fi

# ── 1. Update repo ───────────────────────────────────────────
hdr "Update package list"
inf "Mengupdate repo Termux..."
pkg update -y -q 2>/dev/null && ok "Repo updated" || err "Update gagal (lanjut...)"

# ── 2. Package Termux ────────────────────────────────────────
hdr "Install package Termux"

PKG_LIST=(
    "python"           # Python 3
    "chromium"         # Browser untuk Selenium
    "x11-repo"         # Repo tambahan (diperlukan chromium)
)

for pkg in "${PKG_LIST[@]}"; do
    inf "Menginstall $pkg..."
    if pkg install -y "$pkg" -q 2>/dev/null; then
        ok "$pkg"
    else
        err "$pkg gagal — coba manual: pkg install $pkg"
    fi
done

# ── 3. Pastikan pip up-to-date ───────────────────────────────
hdr "Update pip"
inf "Mengupdate pip..."
python -m pip install --upgrade pip --break-system-packages -q 2>/dev/null \
    && ok "pip updated" || inf "pip sudah terbaru"

# ── 4. Package Python (pip) ──────────────────────────────────
hdr "Install library Python"

PIP_LIST=(
    "rich"             # UI terminal (panel, progress bar, dll)
    "selenium"         # Otomasi browser
    "cryptography"     # AES enkripsi lisensi
    "requests"         # HTTP client (opsional, kadang diperlukan selenium)
)

for pkg in "${PIP_LIST[@]}"; do
    inf "pip install $pkg..."
    if python -m pip install "$pkg" --break-system-packages -q 2>/dev/null; then
        ok "$pkg"
    else
        err "$pkg gagal — coba manual: pip install $pkg --break-system-packages"
    fi
done

# ── 5. Cari chromedriver ─────────────────────────────────────
hdr "Cek ChromeDriver"

DRIVER_PATH="/data/data/com.termux/files/usr/bin/chromedriver"
CHROME_PATH="/data/data/com.termux/files/usr/bin/chromium"

if [ -f "$DRIVER_PATH" ]; then
    ok "chromedriver ditemukan: $DRIVER_PATH"
else
    inf "chromedriver belum ada, mencoba install..."
    pkg install -y chromium -q 2>/dev/null
    if [ -f "$DRIVER_PATH" ]; then
        ok "chromedriver berhasil diinstall"
    else
        err "chromedriver tidak ditemukan!"
        echo -e "  ${Y}  Coba manual:${D} pkg install chromium"
    fi
fi

if [ -f "$CHROME_PATH" ]; then
    ok "chromium ditemukan: $CHROME_PATH"
else
    err "chromium tidak ditemukan di $CHROME_PATH"
    echo -e "  ${Y}  Coba manual:${D} pkg install chromium"
fi

# ── 6. Verifikasi import Python ──────────────────────────────
hdr "Verifikasi instalasi"

python -c "
libs = [
    ('rich',                'rich'),
    ('selenium',            'selenium'),
    ('cryptography',        'cryptography'),
    ('requests',            'requests'),
]
ok  = '\033[1;32m✓\033[0m'
err = '\033[1;31m✗\033[0m'
for label, mod in libs:
    try:
        __import__(mod)
        print(f'  {ok}  {label}')
    except ImportError:
        print(f'  {err}  {label}  ← GAGAL, install manual')
"

# ── 7. Cek versi Python ──────────────────────────────────────
hdr "Info sistem"
PY_VER=$(python --version 2>&1)
ok "Python: $PY_VER"
ok "Termux prefix: $PREFIX"

# ── Selesai ──────────────────────────────────────────────────
echo ""
echo -e "${C}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo -e "${G}  ✅  Instalasi selesai!${D}"
echo ""
echo -e "  ${W}Cara jalankan tool:${D}"
echo -e "  ${C}  python fanzx_enc.py${D}"
echo ""
echo -e "  ${W}Jika ada error saat jalan, coba:${D}"
echo -e "  ${Y}  pip install rich selenium cryptography --break-system-packages${D}"
echo -e "${C}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${D}"
echo ""
