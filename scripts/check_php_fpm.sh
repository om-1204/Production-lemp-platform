#!/bin/bash

SERVICE="php8.3-fpm"

if systemctl is-active --quiet "$SERVICE"; then
    echo "[OK] PHP-FPM is running"
    exit 0
else
    echo "[ALERT] PHP-FPM is DOWN"
    exit 2
fi
