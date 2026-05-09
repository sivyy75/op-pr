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
OPERA_URL="https://github.com/Alexey71/opera-proxy/releases/latest/$FILE"

# Остановка старого процесса
killall opera-proxy 2>/dev/null || true
sleep 1

# Скачивание
# rm -f "$OPERA_BIN"
# log "⬇️ Скачиваю $FILE..."
# wget -O "$OPERA_BIN" "$OPERA_URL" || fail "Не удалось скачать Opera Proxy"
chmod +x "$OPERA_BIN"

# --- [5/6] Автозапуск через procd ---
log "[5/6] ⚙️ Настраиваю автозапуск..."

# Opera Proxy
cat > /etc/init.d/opera-proxy <<'EOF'
#!/bin/sh /etc/rc.common
USE_PROCD=1
START=40
STOP=89
PROG=/usr/bin/opera-proxy
start_service() {
        procd_open_instance
        procd_set_param command "$PROG" -verbosity 50 -bind-address 0.0.0.0:18079 -fake-SNI ya.ru -api-address 77.111.247.15
        procd_set_param stdout 1
        procd_set_param stderr 1
        procd_set_param respawn ${respawn_threshold:-3600} ${respawn_timeout:-5} ${respawn_retry:-5}
        procd_close_instance

        procd_open_instance
        procd_set_param command "$PROG" -verbosity 50 -bind-address 0.0.0.0:18080 -fake-SNI ya.ru -api-address 77.111.247.15
        procd_set_param stdout 1
        procd_set_param stderr 1
        procd_set_param respawn ${respawn_threshold:-3600} ${respawn_timeout:-5} ${respawn_retry:-5}
        procd_close_instance

        procd_open_instance
        procd_set_param command "$PROG" -verbosity 50 -country AM -bind-address 0.0.0.0:18081 -fake-SNI ya.ru -api-address 77.111.247.15
        procd_set_param stdout 1
        procd_set_param stderr 1
        procd_set_param respawn ${respawn_threshold:-3600} ${respawn_timeout:-5} ${respawn_retry:-5}
        procd_close_instance
 
        procd_open_instance
        procd_set_param command "$PROG" -verbosity 50 -bind-address 0.0.0.0:18090 -socks-mode -api-address 77.111.247.15
        procd_set_param stdout 1
        procd_set_param stderr 1
        procd_set_param respawn ${respawn_threshold:-3600} ${respawn_timeout:-5} ${respawn_retry:-5}
        procd_close_instance

        procd_open_instance
        procd_set_param command "$PROG" -verbosity 50 -country AM -bind-address 0.0.0.0:18091 -socks-mode -api-address 77.111.247.15
        procd_set_param stdout 1
        procd_set_param stderr 1
        procd_set_param respawn ${respawn_threshold:-3600} ${respawn_timeout:-5} ${respawn_retry:-5}
        procd_close_instance
}
EOF
chmod +x /etc/init.d/opera-proxy
/etc/init.d/opera-proxy enable
/etc/init.d/opera-proxy start

# --- [6/6] Итог ---
log "[6/6] ✅ Установка завершена!"
echo "-----------------------------------"
echo "✅ OperaProxy: используйте как HTTP-прокси на 192.168.1.1:18080"
echo ""
echo "Пример конфига для sing-box / других клиентов:"
echo "{"
echo "  \"type\": \"http\","
echo "  \"server\": \"127.0.0.1\","
echo "  \"server_port\": 18080"
echo "}"
echo "-----------------------------------"
