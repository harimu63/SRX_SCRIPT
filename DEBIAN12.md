# Port Debian 12 — Catatan Perubahan

Fork dari [fahrialimudin/autoscript-vip](https://github.com/fahrialimudin/autoscript-vip)
(base script oleh Arya Blitar, dimodifikasi Fahri Alimudin), ditambah dukungan
**Debian 12 (bookworm)**. Ubuntu 22.04/24.04 tetap didukung. Debian 11 sengaja
tidak dimasukkan.

## Yang diubah (hanya `setup.sh` + `README.md`)

| Lokasi | Perubahan |
|---|---|
| `setup.sh` — gate OS | Dulu: tolak semua kecuali Ubuntu 22.04/24.04. Sekarang: lolos untuk Ubuntu 22.04/24.04 **atau** Debian 12. Debian 11 dan Ubuntu lain tetap ditolak. |
| `setup.sh` — `install_speedtest_ookla()` | Repo Ookla dulu hardcode `os=ubuntu dist=jammy`. Sekarang: kalau `ID=debian`, pakai `os=debian dist=bookworm`; Ubuntu tetap pakai jammy. Gagal di sini tetap non-fatal (speedtest saja yang tidak terpasang). |
| `setup.sh` — `REPO=` | Default diganti ke placeholder `https://raw.githubusercontent.com/USERNAME/NAMA-REPO/main/` — **wajib diganti** dengan username & nama repo fork kamu sebelum upload ke GitHub. |
| `setup.sh` — banner & komentar vnstat | Banner menampilkan "Ubuntu 22.04/24.04 + Debian 12 (port)"; komentar vnstat menyebut Debian 12. |
| `README.md` | Badge Debian 12 + instruksi install dari fork. |

## Yang TIDAK perlu diubah (sudah Debian-friendly)

- Cek OS bagian "IZIN SC" dan `nginx_install()` sudah punya cabang `debian`.
- Semua nama paket di `apt-get install` (nginx, haproxy, dropbear, vnstat, openvpn, easy-rsa, chrony, iptables-persistent, dsb.) tersedia di repo Debian 12.
- SSL memakai acme.sh (bukan snap/certbot) — tidak tergantung distro.
- `rc-local.service` dibuat sendiri oleh script — jalan di Debian 12.
- `haproxy.cfg` memakai directive yang didukung HAProxy 2.6 (Debian 12).
- Patch easy-rsa di `media/openvpn` bersifat kondisional (hanya diterapkan kalau pola lama ditemukan).
- Script menu tidak punya gate OS.

## Yang belum terverifikasi — wajib dites di VPS Debian 12

- **Belum pernah dites install beneran.** Baru `bash -n` (syntax OK) + simulasi logika gate OS.
- Binary bawaan (`media/udp-custom.sh`, `slowdns/dnstt-*`, `slowdns/noobzvpns.zip`, `media/vpn.zip`) belum dipastikan jalan di Debian 12 (kemungkinan besar jalan; risiko terbesar ada di Debian 11, makanya tidak didukung).
- OpenVPN 2.6 (Debian 12) menonaktifkan beberapa directive lama — kalau ada error, cek config di `media/`.

## Cara pakai

1. Ganti `USERNAME`/`NAMA-REPO` di `setup.sh` (baris `REPO=...`).
2. Upload repo ini ke GitHub (repo baru, publik atau privat).
3. Di VPS **Debian 12** fresh, sebagai root:
   ```
   apt update -y && apt install -y wget curl ca-certificates && wget -q https://raw.githubusercontent.com/USERNAME/NAMA-REPO/main/setup.sh && chmod +x setup.sh && ./setup.sh
   ```
4. Domain wajib sudah pointing ke IP VPS (setting Cloudflare: SSL Full, GRPC ON, WebSocket ON, seperti di README).
5. **Tes di VPS percobaan dulu** — jangan langsung di VPS produksi.
