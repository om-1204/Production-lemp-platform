#!/bin/bash

set -e

DB_NAME="veriqta_portal"
BACKUP_DIR="$HOME/production-lemp-platform/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

echo "========================================"
echo " VERIQTA Database Backup"
echo "========================================"

echo "[1/3] Creating database backup..."

sudo mariadb-dump "$DB_NAME" > "$BACKUP_FILE"

echo "[2/3] Verifying backup file..."

if [ -s "$BACKUP_FILE" ]; then
    echo "Backup created successfully:"
    echo "$BACKUP_FILE"
else
    echo "ERROR: Backup file is empty."
    rm -f "$BACKUP_FILE"
    exit 1
fi

echo "[3/3] Checking backup..."

sudo mariadb-dump --no-data "$DB_NAME" >/dev/null

echo
echo "========================================"
echo " DATABASE BACKUP SUCCESS"
echo "========================================"
