#!/bin/bash

# ======================================
# LEMP SERVICE RECOVERY
# ======================================

PROJECT_DIR="$HOME/production-lemp-platform"
LOG_DIR="$PROJECT_DIR/evidence/health-check"
LOG_FILE="$LOG_DIR/service_recovery.log"

mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

log "======================================"
log "       LEMP SERVICE RECOVERY"
log "======================================"

SERVICES=("nginx" "php8.3-fpm" "mariadb")

RECOVERY_FAILED=0

for service in "${SERVICES[@]}"; do

    if systemctl is-active --quiet "$service"; then
        log "[OK] $service is already running"
    else
        log "[FAIL] $service is not running"
        log "[ACTION] Attempting to restart $service"

        if sudo systemctl restart "$service"; then
            sleep 2

            if systemctl is-active --quiet "$service"; then
                log "[RECOVERED] $service restarted successfully"
            else
                log "[CRITICAL] $service failed to start"
                RECOVERY_FAILED=1
            fi
        else
            log "[CRITICAL] Restart command failed for $service"
            RECOVERY_FAILED=1
        fi
    fi

done

log ""
log "---- Application Verification ----"

if curl -fsS http://localhost/ > /dev/null; then
    log "[OK] Application is responding"
else
    log "[CRITICAL] Application is NOT responding"
    RECOVERY_FAILED=1
fi

log ""
log "======================================"

if [ "$RECOVERY_FAILED" -eq 0 ]; then
    log "FINAL STATUS: RECOVERY CHECK PASSED"
    exit 0
else
    log "FINAL STATUS: RECOVERY FAILED"
    exit 1
fi
