#!/bin/sh
set -e

echo "=============================="
echo "установка OperaProxy (LuCI)"
echo "=============================="

log() { echo "[$(date +'%T')] $*"; }
fail() { echo "❌ $*" >&2; exit 1; }

# --- [2/6] Установка Opera Proxy ---
log "[2/6] ⬇️ Устанавливаю Opera Proxy..."

ARCH=$(uname -m)
case "$ARCH" in
    aarch64|arm64) FILE="opera-proxy.linux-arm64" ;;
    x86_64)        FILE="opera-proxy.linux-amd64" ;;
    mips*)         fail "Архитектура $ARCH не поддерживается Opera Proxy" ;;
    *)             fail "Неизвестная архитектура: $ARCH" ;;
esac

OPERA_BIN="/usr/bin/opera-proxy_Alexey71"
# 🔥 ИСПРАВЛЕНО: убраны пробелы в URL!
# OPERA_URL="https://github.com/Alexey71/opera-proxy/releases/download/v1.19.1/$FILE"
LATEST_TAG=$(curl -s https://api.github.com/repos/Alexey71/opera-proxy/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
OPERA_URL="https://github.com/Alexey71/opera-proxy/releases/download/$LATEST_TAG/$FILE"

# Остановка старого процесса
killall opera-proxy_Alexey71 2>/dev/null || true
sleep 1

# Скачивание
rm -f "$OPERA_BIN"
log "⬇️ Скачиваю $FILE..."
wget -O "$OPERA_BIN" "$OPERA_URL" || fail "Не удалось скачать Opera Proxy"
chmod +x "$OPERA_BIN"

/etc/init.d/opera-proxy_Alexey71 enable
/etc/init.d/opera-proxy_Alexey71 start

# --- [6/6] Итог ---
log "[6/6] ✅ Установка завершена!"
echo "-----------------------------------"
echo "✅ OperaProxy: используйте как HTTP-прокси на 192.168.1.1:18180"
echo ""
echo "Пример конфига для sing-box / других клиентов:"
echo "{"
echo "  \"type\": \"http\","
echo "  \"tag\": \"eu-http\","
echo "  \"server\": \"127.0.0.1\","
echo "  \"server_port\": 18180"
echo "}"
echo "-----------------------------------"
