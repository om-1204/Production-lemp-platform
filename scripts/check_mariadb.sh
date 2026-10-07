#!/bin/bash

SERVICE="mariadb"

if systemctl is-active --quiet "$SERVICE"; then
    echo "[OK] MariaDB is running"
    exit 0
else
    echo "[ALERT] MariaDB is DOWN"
    exit 2
fi
