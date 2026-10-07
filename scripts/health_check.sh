#!/bin/bash

# ======================================
# LEMP APPLICATION HEALTH CHECK
# ======================================

PROJECT_DIR="$HOME/production-lemp-platform"
LOG_DIR="$PROJECT_DIR/evidence/health-check"
LOG_FILE="$LOG_DIR/health_check.log"

mkdir -p "$LOG_DIR"

# Status tracking
STATUS=0

# Logging function
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "======================================"
log "      LEMP APPLICATION HEALTH CHECK"
log "======================================"

log ""
log "Date: $(date)"
log "Hostname: $(hostname)"

# --------------------------------------
# Service Status
# --------------------------------------

log ""
log "---- Service Status ----"

SERVICES=("nginx" "php8.3-fpm" "mariadb")

for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        log "[OK] $service is running"
    else
        log "[CRITICAL] $service is NOT running"
        STATUS=2
    fi
done

# --------------------------------------
# Disk Usage
# --------------------------------------

log ""
log "---- Disk Usage ----"

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

log "Root filesystem usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -ge 90 ]; then
    log "[CRITICAL] Disk usage is ${DISK_USAGE}%"
    STATUS=2
elif [ "$DISK_USAGE" -ge 70 ]; then
    log "[WARNING] Disk usage is ${DISK_USAGE}%"

    if [ "$STATUS" -eq 0 ]; then
        STATUS=1
    fi
else
    log "[OK] Disk usage is ${DISK_USAGE}%"
fi

# --------------------------------------
# Memory Usage
# --------------------------------------

log ""
log "---- Memory Usage ----"

MEMORY_USAGE=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')

log "Memory usage: ${MEMORY_USAGE}%"

if [ "$MEMORY_USAGE" -ge 90 ]; then
    log "[CRITICAL] Memory usage is ${MEMORY_USAGE}%"
    STATUS=2
elif [ "$MEMORY_USAGE" -ge 75 ]; then
    log "[WARNING] Memory usage is ${MEMORY_USAGE}%"

    if [ "$STATUS" -eq 0 ]; then
        STATUS=1
    fi
else
    log "[OK] Memory usage is ${MEMORY_USAGE}%"
fi

# --------------------------------------
# CPU Load
# --------------------------------------

log ""
log "---- CPU Load ----"

LOAD=$(awk '{print $1}' /proc/loadavg)

log "1-minute load average: $LOAD"

# --------------------------------------
# Application Check
# --------------------------------------

log ""
log "---- Application Check ----"

if curl -fsS http://localhost/ > /dev/null; then
    log "[OK] Application is responding"
else
    log "[CRITICAL] Application is NOT responding"
    STATUS=2
fi

# --------------------------------------
# Final Status
# --------------------------------------

log ""
log "======================================"

if [ "$STATUS" -eq 0 ]; then
    log "FINAL STATUS: HEALTHY"
elif [ "$STATUS" -eq 1 ]; then
    log "FINAL STATUS: WARNING"
else
    log "FINAL STATUS: CRITICAL"
fi

log "======================================"

exit "$STATUS"
