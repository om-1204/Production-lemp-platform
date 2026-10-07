#!/bin/bash

set -e

APP_DIR="/srv/veriqta-portal"
NGINX_SITE="/etc/nginx/sites-enabled/portal.veriqta.test"
HEALTH_URL="http://portal.veriqta.test/health.php"

echo "========================================"
echo " VERIQTA Portal Deployment Validation"
echo "========================================"

echo "[1/5] Checking PHP syntax..."

php -l "$APP_DIR/public/index.php"
php -l "$APP_DIR/public/health.php"
php -l "$APP_DIR/src/database.php"

echo "[2/5] Checking Nginx configuration..."

nginx -t

echo "[3/5] Checking PHP-FPM..."

systemctl is-active --quiet php8.3-fpm

echo "PHP-FPM: active"

echo "[4/5] Reloading Nginx..."

systemctl reload nginx

echo "Nginx: reloaded"

echo "[5/5] Checking application health..."

HEALTH_RESPONSE=$(curl -fsS "$HEALTH_URL")

echo "Health response:"
echo "$HEALTH_RESPONSE"

if echo "$HEALTH_RESPONSE" | grep -q '"status":"healthy"'; then
    echo
    echo "========================================"
    echo " DEPLOYMENT VALIDATION SUCCESS"
    echo "========================================"
else
    echo
    echo "ERROR: Application health check failed."
    exit 1
fi
