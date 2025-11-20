#!/bin/bash
chmod +x recon-auto.sh
./recon-auto.sh

INPUT_FILE="../input/domains.txt"
ALL_SUBDOMAINS="../output/all-subdomains.txt"
LIVE_HOSTS="../output/live.txt"
PROGRESS_LOG="../logs/progress.log"
ERROR_LOG="../logs/errors.log"

# Create/clear output and log files
> "$ALL_SUBDOMAINS"
> "$LIVE_HOSTS"
> "$PROGRESS_LOG"
> "$ERROR_LOG"

echo "[INFO] Starting recon at $(date)" | tee -a "$PROGRESS_LOG"

while read -r domain; do
    echo "[INFO] Enumerating $domain at $(date)" | tee -a "$PROGRESS_LOG"
    
    subfinder -d "$domain" -silent 2>>"$ERROR_LOG" | anew "$ALL_SUBDOMAINS" | tee -a "$PROGRESS_LOG"
    
done < "$INPUT_FILE"

echo "[INFO] Checking live hosts at $(date)" | tee -a "$PROGRESS_LOG"

httpx -silent -status-code -title -l "$ALL_SUBDOMAINS" 2>>"$ERROR_LOG" | anew "$LIVE_HOSTS" | tee -a "$PROGRESS_LOG"

echo "[INFO] Recon finished at $(date)" | tee -a "$PROGRESS_LOG"

# Summary
echo "[SUMMARY] Total unique subdomains: $(wc -l < "$ALL_SUBDOMAINS")" | tee -a "$PROGRESS_LOG"
echo "[SUMMARY] Total live hosts: $(wc -l < "$LIVE_HOSTS")" | tee -a "$PROGRESS_LOG"
