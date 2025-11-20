# recon-automation-ricky

## Deskripsi
Script ini mengotomasi proses recon: enumerasi subdomain menggunakan subfinder, deduplikasi menggunakan anew, dan pengecekan host aktif menggunakan httpx lalu hasil akhir tersimpan di `output/live.txt` dan log di `logs/`.

## Persyaratan
- Bash (Linux/macOS/WSL)
- go (untuk install go-based tools)
- subfinder (https://github.com/projectdiscovery/subfinder)
- anew (https://github.com/tomnomnom/anew)
- httpx (https://github.com/projectdiscovery/httpx)
- git

## Instalasi
```bash
# instal anew
go install -v github.com/tomnomnom/anew@latest
# instal subfinder
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
# instal httpx
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

## Cara Menjalankan Script
- Masukkan domain ke input/domains.txt
- Jalankan script:
cd scripts
./recon-auto.sh


- Hasil akan muncul di folder output/

## Contoh Input & Output
Contoh Input:
tesla.com

Contoh Output:
output/live.txt contohnya berisi baris seperti:
http://shop.tesla.com [200] [Tesla Shop]

## Penjelasan Script
Script  akan:
1. 	Membaca domains.txt
2. 	Menjalankan subfinder dan assetfinder untuk enumerasi subdomain
3. 	Menggabungkan dan menyaring hasil
4. 	Mengecek host yang aktif dengan httpx
5. 	Menyimpan hasil ke output/ dan log ke logs/

# Script ini dijalankan menggunakan interpreter Bash.
#!/bin/bash

# Path file input dan output agar mudah digunakan di seluruh script.
INPUT_FILE="../input/domains.txt"
ALL_SUBDOMAINS="../output/all-subdomains.txt"
LIVE_HOSTS="../output/live.txt"
PROGRESS_LOG="../logs/progress.log"
ERROR_LOG="../logs/errors.log"

# Membersihkan isi file output dan log sebelum proses dimulai 
> "$ALL_SUBDOMAINS"
> "$LIVE_HOSTS"
> "$PROGRESS_LOG"
> "$ERROR_LOG"

# Menampilkan dan mencatat waktu mulai proses ke progress.log dengan tee.
echo "[INFO] Starting recon at $(date)" | tee -a "$PROGRESS_LOG"

# Memulai loop untuk membaca setiap baris (domain) dari file domains.txt.
while read -r domain; do

# Menampilkan dan mencatat domain yang sedang diproses beserta timestamp.
 echo "[INFO] Enumerating $domain at $(date)" | tee -a "$PROGRESS_LOG"

# Menjalankan subfinder untuk enumerasi subdomain, Output disaring agar tidak duplikat menggunakan anew, lalu disimpan ke all-subdomains.txt, Semua output dicatat ke progress.log, jika ada error, dialihkan ke errors.log.
subfinder -d "$domain" -silent 2>>"$ERROR_LOG" | anew "$ALL_SUBDOMAINS" | tee -a "$PROGRESS_LOG"

# Menutup loop dan memastikan semua domain dari file input diproses.
done < "$INPUT_FILE"

# Proses pengecekan host aktif.
echo "[INFO] Checking live hosts at $(date)" | tee -a "$PROGRESS_LOG"

# Menjalankan httpx untuk mengecek status dan title dari subdomain yang ditemukan, Output disaring agar unik dengan anew, lalu disimpan ke live.txt, Semua hasil dicatat ke progress.log, error dialihkan ke errors.log.
httpx -silent -status-code -title -l "$ALL_SUBDOMAINS" 2>>"$ERROR_LOG" | anew "$LIVE_HOSTS" | tee -a "$PROGRESS_LOG"

# Proses recon berakhir dan mencatat waktu selesai.
echo "[INFO] Recon finished at $(date)" | tee -a "$PROGRESS_LOG"

# Menampilkan dan mencatat jumlah subdomain unik dan host aktif yang ditemukan.
echo "[SUMMARY] Total unique subdomains: $(wc -l < "$ALL_SUBDOMAINS")" | tee -a "$PROGRESS_LOG"
echo "[SUMMARY] Total live hosts: $(wc -l < "$LIVE_HOSTS")" | tee -a "$PROGRESS_LOG"

## Screenshot terminal (eksekusi + hasil live.txt)
<img width="2560" height="1379" alt="Screenshot 2025-11-20 100537" src="https://github.com/user-attachments/assets/c056eb11-1a16-4cf9-862d-e88d779964f2" />

<img width="2560" height="1379" alt="Screenshot 2025-11-20 100804" src="https://github.com/user-attachments/assets/310b4fe2-b906-417d-801b-acdea3b96b73" />
