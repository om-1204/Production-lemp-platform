#!/bin/bash

# ======================================
# LEMP LOG & DISK CLEANUP
# ======================================

PROJECT_DIR="$HOME/production-lemp-platform"
LOG_DIR="$PROJECT_DIR/evidence/log-cleanup"
LOG_FILE="$LOG_DIR/log_cleanup.log"

mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

log "======================================"
log "       LEMP LOG & DISK CLEANUP"
log "======================================"

# --------------------------------------
# Disk Usage
# --------------------------------------

log ""
log "---- Disk Usage ----"

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

log "Root filesystem usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -ge 90 ]; then
    log "[CRITICAL] Disk usage is ${DISK_USAGE}%"
elif [ "$DISK_USAGE" -ge 70 ]; then
    log "[WARNING] Disk usage is ${DISK_USAGE}%"
else
    log "[OK] Disk usage is ${DISK_USAGE}%"
fi

# --------------------------------------
# Log Directory Analysis
# --------------------------------------

log ""
log "---- Log Directory Sizes ----"

for directory in /var/log/nginx /var/log/mysql /var/log/php*; do
    if [ -d "$directory" ]; then
        SIZE=$(du -sh "$directory" 2>/dev/null | awk '{print $1}')
        log "[INFO] $directory -> $SIZE"
    fi
done

# --------------------------------------
# Large Log Files
# --------------------------------------

log ""
log "---- Large Log Files (>100 MB) ----"

LARGE_LOGS=$(sudo find /var/log -type f -size +100M -printf '%s %p\n' 2>/dev/null | sort -nr)

if [ -n "$LARGE_LOGS" ]; then
    echo "$LARGE_LOGS" | while read -r SIZE FILE; do
        SIZE_MB=$((SIZE / 1024 / 1024))
        log "[WARNING] Large log: ${FILE} (${SIZE_MB} MB)"
    done
else
    log "[OK] No log files larger than 100 MB found"
fi

# --------------------------------------
# Project Evidence Size
# --------------------------------------

log ""
log "---- Project Evidence Size ----"

EVIDENCE_SIZE=$(du -sh "$PROJECT_DIR/evidence" 2>/dev/null | awk '{print $1}')

log "Evidence directory size: $EVIDENCE_SIZE"

# --------------------------------------
# Safe Old Log Cleanup
# --------------------------------------

log ""
log "---- Old Compressed Log Cleanup ----"

OLD_LOGS=$(sudo find /var/log -type f -name "*.gz" -mtime +7 2>/dev/null)

if [ -n "$OLD_LOGS" ]; then

    log "[INFO] Old compressed logs found:"

    echo "$OLD_LOGS" | while read -r FILE; do
        log "[DELETE] $FILE"
        sudo rm -f "$FILE"
    done

    log "[OK] Old compressed logs cleaned"

else
    log "[OK] No compressed logs older than 7 days found"
fi

# --------------------------------------
# Final Status
# --------------------------------------

log ""
log "======================================"
log "FINAL STATUS: LOG ANALYSIS COMPLETED"
log "======================================"

exit 0
