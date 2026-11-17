# 📱 TELEGRAM BACKUP SYSTEM - USER GUIDE

## 📋 Gambaran Umum

Fitur backup telah diubah dari sistem email (yang error) menjadi **Telegram Bot Backup System**. Sistem baru ini lebih reliable, gratis, dan mudah digunakan.

---

## ✨ Fitur Utama

- ✅ **Backup Manual** - Backup kapan saja via menu
- ✅ **Auto Backup** - Backup otomatis setiap hari jam 03:00 WIB
- ✅ **Upload ke Telegram** - File backup dikirim ke Telegram Bot
- ✅ **Auto Delete Old Backups** - Hanya simpan 3 backup terakhir
- ✅ **Restore Mudah** - Pilih dari list atau input file_id
- ✅ **Notifikasi Real-time** - Dapat notif setiap backup/restore
- ✅ **File Size Check** - Validasi ukuran file (max 50MB via Bot API)

---

## 🔄 UPDATE UNTUK USER LAMA

Jika Anda sudah install script sebelumnya, **tidak perlu install ulang!**

```bash
# Update menu script
menu → [12] UPDATE MENU

# Atau langsung
update-menu
```

**Yang terjadi saat update:**
- ✅ Semua menu ter-update otomatis
- ✅ Telegram Backup handler ter-install
- ✅ Dependencies (jq, bc) ter-install
- ✅ Backup lama tetap kompatibel

---

## 🚀 Cara Setup Telegram Bot

### Step 1: Buat Bot di Telegram

1. Buka Telegram, cari **@BotFather**
2. Kirim command: `/newbot`
3. Ikuti instruksi:
   - Masukkan nama bot (contoh: `MyVPS Backup Bot`)
   - Masukkan username bot (contoh: `myvps_backup_bot`)
4. **Simpan BOT_TOKEN** yang diberikan (format: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### Step 2: Dapatkan CHAT_ID

**Opsi A: Private Chat (Recommended)**
1. Cari bot Anda di Telegram (contoh: `@myvps_backup_bot`)
2. Klik **START** atau kirim pesan apapun
3. Cari **@userinfobot** atau **@getidsbot**
4. Forward pesan dari bot Anda ke @userinfobot
5. **Simpan CHAT_ID** yang diberikan (format: `123456789`)

**Opsi B: Group Chat**
1. Buat group baru di Telegram
2. Tambahkan bot Anda ke group
3. Kirim pesan di group
4. Cari **@getidsbot**, tambahkan ke group
5. **Simpan CHAT_ID** group (format: `-1001234567890`)
6. Hapus @getidsbot dari group

### Step 3: Setup di VPS

1. Login ke VPS sebagai root
2. Jalankan command: `menu`
3. Pilih **[8] BCKP/RSTR**
4. Pilih **[3] Auto Backup Data**
5. Pilih **[1] Setup Telegram Bot**
6. Masukkan **BOT_TOKEN** dan **CHAT_ID**
7. Bot akan test koneksi otomatis

---

## 📖 Cara Menggunakan

### 🔹 Manual Backup

```bash
# Dari menu utama
menu
>> Pilih [8] BCKP/RSTR
>> Pilih [1] Backup Data

# Atau langsung
backup
```

**Yang Dibackup:**
- `/etc/passwd`, `/etc/group`, `/etc/shadow`, `/etc/gshadow`
- `/etc/crontab`
- `/var/lib/kyt/` (limit & quota data)
- `/etc/xray/` (konfigurasi Xray)
- `/var/www/html/` (web files)
- `/etc/openvpn/` (OpenVPN configs)

**Output:**
- File ZIP dikirim ke Telegram
- Notifikasi berisi: IP, Domain, Size, Date, File_ID
- Backup tersimpan di Telegram chat

---

### 🔹 Auto Backup

```bash
# Setup Auto Backup
menu >> [8] >> [3] >> [1] Setup Telegram Bot
menu >> [8] >> [3] >> [2] Start Autobackup

# Status
menu >> [8] >> [3]  # Lihat status ON/OFF

# Stop Auto Backup
menu >> [8] >> [3] >> [3] Stop Autobackup

# Ubah Waktu Backup
menu >> [8] >> [3] >> [4] Change Backup Time
```

**Default Schedule:**
- **Waktu**: 03:00 AM (GMT+7) setiap hari
- **Keep**: 3 backup terakhir
- **Auto Delete**: Backup lama dihapus otomatis

---

### 🔹 Restore Backup

```bash
# Dari menu
menu >> [8] >> [2] Restore Data
```

**3 Metode Restore:**

**1. List dari Telegram (Recommended)**
- Bot akan tampilkan 3 backup terakhir
- Pilih nomor backup yang ingin direstore
- Otomatis download & restore

**2. Manual File_ID**
- Copy file_id dari notifikasi Telegram
- Paste ke menu restore
- Manual download & restore

**3. External URL**
- Untuk backup dari Google Drive / Dropbox
- Masukkan direct download link
- Compatible dengan backup lama

**Proses Restore:**
1. Download backup dari Telegram
2. Extract file ZIP
3. Restore semua config
4. Restart services (xray, nginx, ssh, openvpn, dll)
5. Kirim notifikasi restore sukses

---

## 🔧 Troubleshooting

### ❌ Error: "Invalid BOT_TOKEN"
**Solusi:**
- Pastikan copy BOT_TOKEN lengkap dari @BotFather
- Format harus: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`
- Jangan ada spasi di awal/akhir

### ❌ Error: "Failed to send test message"
**Solusi:**
- Pastikan bot sudah di-START (kirim /start ke bot)
- Jika pakai group, pastikan bot sudah ditambahkan
- CHAT_ID harus benar (pakai @userinfobot)
- Format CHAT_ID: `123456789` (private) atau `-1001234567890` (group)

### ❌ Error: "File size exceeds 50MB limit"
**Solusi:**
- Telegram Bot API limit: 50MB
- Bersihkan log terlebih dahulu:
  ```bash
  menu >> [8] >> [4] Cleaner Data
  ```
- Atau hapus file besar di `/var/www/html/`

### ❌ Error: "No backups found in Telegram"
**Solusi:**
- Pastikan sudah ada backup sebelumnya
- Gunakan opsi "Manual file_id" atau "External URL"
- Cek chat Telegram manual untuk file backup

### ❌ Autobackup tidak jalan
**Solusi:**
- Cek status cron:
  ```bash
  systemctl status cron
  service cron status
  ```
- Cek crontab:
  ```bash
  cat /etc/crontab | grep Backup
  ```
- Test manual:
  ```bash
  /usr/local/sbin/backup
  ```

### ❌ Update menu tidak install Telegram Backup
**Solusi:**
- Jalankan ulang update:
  ```bash
  update-menu
  ```
- Atau install manual:
  ```bash
  wget https://raw.githubusercontent.com/USERNAME/REPO/main/media/telegram-backup.sh -O /usr/local/sbin/telegram-backup-handler.sh
  chmod 755 /usr/local/sbin/telegram-backup-handler.sh
  apt-get install -y jq bc
  ```

---

## 📊 Perbandingan: Email vs Telegram

| Fitur | Email (Lama) | Telegram (Baru) |
|-------|--------------|-----------------|
| **Setup** | Kompleks (SMTP config) | Mudah (2 menit) |
| **Reliability** | ❌ Sering error | ✅ Stabil |
| **Cost** | Google Drive API quota | ✅ Gratis |
| **Speed** | Lambat (upload Drive) | ⚡ Cepat |
| **Storage** | Terbatas | ✅ 2GB per file |
| **Notifikasi** | Email tertunda | ✅ Real-time |
| **Restore** | Manual download | ✅ Auto download |
| **History** | Sulit tracking | ✅ Semua di chat |

---

## 🔐 Keamanan

- ✅ Config file permission: `600` (hanya root)
- ✅ BOT_TOKEN tidak disimpan di log
- ✅ File backup otomatis dihapus setelah upload
- ✅ Support private chat & group chat
- ⚠️ **PENTING**: Jangan share BOT_TOKEN dengan orang lain
- ⚠️ **PENTING**: Gunakan private chat atau group private

---

## 🎯 Quick Commands

```bash
# Setup
menu >> 8 >> 3 >> 1  # Setup Telegram Bot
menu >> 8 >> 3 >> 2  # Enable Autobackup

# Backup
backup               # Manual backup

# Restore
restore              # Restore from Telegram

# Update
update-menu          # Update script & install Telegram Backup

# Test
menu >> 8 >> 3 >> 6  # Test Telegram connection
```

---

**✅ Selamat! Backup system Anda sekarang menggunakan Telegram Bot yang lebih reliable!**

---

## 📞 Support & Credits

- **Modified by**: Kiro AI (Telegram Backup Integration)
- **Original Script**: Fahri Alimudin (@fahrialimudin)
- **Base Script**: Arya Blitar

**Dokumentasi ini dibuat pada**: 2026-11-17
