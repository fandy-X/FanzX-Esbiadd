import os, sys, hashlib, subprocess, socket, uuid

# JANGAN DI EDIT FILE INI


def get_hwid():
    hf = os.path.join(os.path.expanduser("~"), ".fanzx_hwid")
    if os.path.exists(hf):
        try:
            s = open(hf).read().strip()
            if len(s) == 16 and s.isalnum():
                return s.upper()
        except: pass
    seeds = []
    for prop in ["ro.serialno","ro.boot.serialno","ro.product.model",
                 "ro.product.brand","ro.build.fingerprint"]:
        try:
            v = subprocess.check_output(["getprop",prop],
                stderr=subprocess.DEVNULL,timeout=2).decode().strip()
            if v: seeds.append(v)
        except: pass
    try:
        with open("/proc/cpuinfo") as f:
            for line in f:
                if line.lower().startswith(("hardware","serial")):
                    seeds.append(line.split(":")[-1].strip())
    except: pass
    seeds.append(os.path.expanduser("~"))
    try: seeds.append(socket.gethostname())
    except: pass
    raw  = "|".join(seeds) if seeds else str(uuid.uuid4())
    hwid = hashlib.sha256(raw.encode()).hexdigest()[:16].upper()
    try:
        with open(hf,"w") as f: f.write(hwid)
    except: pass
    return hwid

hwid = get_hwid()
print("\n" + "="*40)
print("   FANZX — HWID CHECKER")
print("="*40)
print(f"\n   HWID Device : {hwid}\n")
print("   Kirim HWID di atas")
print("   Ke wa ini 083844260377")
print("   untuk mendapatkan tool run dan lisensi.\n")
print("="*40 + "\n")
input("   Tekan Enter untuk keluar...")
