#!/bin/sh

flask_alive() {
    curl -sf --max-time 2 http://127.0.0.1:5801/api/status >/dev/null 2>&1
}

chromium_alive() {
    curl -sf --max-time 2 http://127.0.0.1:9222/json/version >/dev/null 2>&1
}

if [ -f /app/start.py ]; then
    flask_alive && chromium_alive
    exit $?
fi

chromium_alive
exit $?