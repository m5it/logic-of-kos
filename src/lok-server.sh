#!/bin/bash
# LoK HTTP API Server
# Usage: lok-server.sh [start|stop|restart|status]

CONFIG_DIR="$HOME/.config/lok"
TOKEN_FILE="$CONFIG_DIR/server_token"
PID_FILE="/tmp/lok-server.pid"
PORT=19876

# Generate token if not exists
generate_token() {
    mkdir -p "$CONFIG_DIR"
    token=$(head -c 32 /dev/urandom | xxd -p -c 32)
    echo "$token" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    echo "Generated new token: $token"
    echo "Save this token for clients in ~/.config/lok/remotes.conf"
}

# Get token
get_token() {
    if [[ ! -f "$TOKEN_FILE" ]]; then
        generate_token
    fi
    cat "$TOKEN_FILE"
}

start_server() {
    if [[ -f "$PID_FILE" ]]; then
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Server already running (PID: $pid)"
            return 1
        fi
    fi
    
    echo "Starting LoK server on port $PORT..."
    TOKEN=$(get_token)
    echo "Token: $TOKEN"
    
    # Use socat if available
    if command -v socat >/dev/null 2>&1; then
        echo "Using socat"
        (while true; do
            socat -T 10 TCP-LISTEN:$PORT,reuseaddr,fork "SYSTEM:$0 handler $TOKEN" 2>/dev/null
        done) &
        echo $! > "$PID_FILE"
    else
        echo "Error: socat required. Install: sudo apt install socat"
        return 1
    fi
    
    echo "Server started (PID: $(cat $PID_FILE))"
}

stop_server() {
    if [[ -f "$PID_FILE" ]]; then
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            rm -f "$PID_FILE"
            echo "Server stopped"
        else
            echo "Server not running"
            rm -f "$PID_FILE"
        fi
    else
        echo "Server not running"
    fi
}

status_server() {
    if [[ -f "$PID_FILE" ]]; then
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Server running (PID: $pid)"
            return 0
        else
            echo "Server not running (stale PID file)"
            return 1
        fi
    else
        echo "Server not running"
        return 1
    fi
}

# Handler for socat
handler() {
    local token="$1"
    local request line path method auth_token cmd result
    
    # Read request with timeout
    read -r -t 5 request || exit 1
    
    method=$(echo "$request" | cut -d' ' -f1)
    path=$(echo "$request" | cut -d' ' -f2)
    
    # Read headers with timeout
    auth_token=""
    while read -r -t 2 line; do
        [[ -z "$line" ]] && break
        if [[ "$line" =~ ^Authorization:[[:space:]]+Bearer[[:space:]]+(.*)$ ]]; then
            auth_token="${BASH_REMATCH[1]}"
        fi
    done
    
    # Validate token
    if [[ "$auth_token" != "$token" ]]; then
        send_response 401 "Unauthorized"
        exit 1
    fi
    
    # Handle request
    case "$path" in
        /ping)
            send_response 200 "pong"
            ;;
        /run)
            # Read body
            read -r -t 5 body || {
                send_response 400 "Missing body"
                exit 1
            }
            cmd=$(echo "$body" | grep -oP '(?<=cmd=).*?(?=&)')
            if [[ -z "$cmd" ]]; then
                send_response 400 "Missing cmd parameter"
                exit 1
            fi
            # Execute command safely
            result=$(cd "$(dirname "$0")/.." && ./lok.sh $cmd 2>&1)
            status=$?
            send_response 200 "$result"
            ;;
        *)
            send_response 404 "Not found"
            ;;
    esac
}

send_response() {
    local code=$1
    local msg="$2"
    echo -e "HTTP/1.1 $code\r"
    echo -e "Content-Type: text/plain\r"
    echo -e "Connection: close\r"
    echo -e "\r"
    echo "$msg"
}

# Main
case "${1:-start}" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    restart)
        stop_server
        sleep 1
        start_server
        ;;
    status)
        status_server
        ;;
    handler)
        handler "$2"
        ;;
    *)
        echo "Usage: $0 [start|stop|restart|status]"
        ;;
esac
