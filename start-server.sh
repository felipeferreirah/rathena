#!/usr/bin/env bash
# ============================================================================
# rAthena - Gerenciador de Servidor (Login / Char / Map / Web / Tool)
# Uso:
#   ./start-server.sh start|stop|restart|status|monitor|autorestart|tail
# ============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$ROOT_DIR/log"
RUN_DIR="$ROOT_DIR/run"

# Binários
LOGIN="$ROOT_DIR/login-server"
CHAR="$ROOT_DIR/char-server"
MAP="$ROOT_DIR/map-server"
WEB="$ROOT_DIR/web-server"
TOOL="$ROOT_DIR/tool-server"   # caso venha a existir

# Criação de pastas de suporte
mkdir -p "$LOG_DIR" "$RUN_DIR"

# ------------------- Funções Auxiliares -------------------

get_pid() {
  local f="$1"
  [[ -f "$f" ]] && cat "$f" 2>/dev/null || echo ""
}

is_running() {
  local pid="$1"
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

start_one() {
  local name="$1" bin="$2" logf="$3" pidf="$4"
  local pid
  pid="$(get_pid "$pidf")"

  if is_running "$pid"; then
    echo "[INFO] $name já está rodando (PID $pid)"
    return 0
  fi

  if [[ ! -x "$bin" ]]; then
    echo "[ERRO] Binário não encontrado: $bin"
    return 1
  fi

  echo "[INFO] Iniciando $name..."
  nohup "$bin" >> "$logf" 2>&1 &
  pid=$!
  echo "$pid" > "$pidf"
  sleep 0.5

  if is_running "$pid"; then
    echo "[OK] $name iniciado (PID $pid) — log: $logf"
  else
    echo "[ERRO] Falha ao iniciar $name — verifique $logf"
  fi
}

stop_one() {
  local name="$1" pidf="$2"
  local pid
  pid="$(get_pid "$pidf")"

  if ! is_running "$pid"; then
    echo "[INFO] $name não está rodando."
    [[ -f "$pidf" ]] && rm -f "$pidf"
    return 0
  fi

  echo "[INFO] Parando $name (PID $pid)..."
  kill "$pid" || true
  sleep 1

  if is_running "$pid"; then
    echo "[WARN] $name não respondeu — forçando término..."
    kill -9 "$pid" || true
  fi

  rm -f "$pidf"
  echo "[OK] $name parado."
}

# ------------------- Modo de Monitoramento -------------------

monitor() {
  clear
  echo "=== Monitoramento rAthena (login / char / map / web / tool) ==="
  echo "(Ctrl+C para sair)"
  while true; do
    echo ""
    for svc in login char map web tool; do
      pidf="$RUN_DIR/${svc}.pid"
      pid="$(get_pid "$pidf")"
      if is_running "$pid"; then
        uptime=$(ps -p "$pid" -o etime= | tr -d ' ')
        echo "[OK]   ${svc}-server rodando (PID $pid | Uptime: $uptime)"
      else
        echo "[FAIL] ${svc}-server parado"
      fi
    done
    echo ""
    echo "---------------------------------------------"
    sleep 3
    clear
    echo "=== Monitoramento rAthena (login / char / map / web / tool) ==="
    echo "(Ctrl+C para sair)"
  done
}

# ------------------- Modo Auto-Restart -------------------

auto_recover() {
  echo "[INFO] Modo auto-restart habilitado (Ctrl+C para sair)"
  while true; do
    for svc in login char map web tool; do
      pidf="$RUN_DIR/${svc}.pid"
      pid="$(get_pid "$pidf")"
      if ! is_running "$pid"; then
        echo "[WARN] ${svc}-server caiu! Reiniciando..."
        start_one "${svc}-server" "$ROOT_DIR/${svc}-server" "$LOG_DIR/${svc}.log" "$pidf"
      fi
    done
    sleep 10
  done
}

# ------------------- Execução Principal -------------------

case "${1:-status}" in
  start)
    echo "=== Iniciando Servidores rAthena ==="
    start_one "login-server" "$LOGIN" "$LOG_DIR/login.log" "$RUN_DIR/login.pid"
    start_one "char-server"  "$CHAR"  "$LOG_DIR/char.log"  "$RUN_DIR/char.pid"
    start_one "map-server"   "$MAP"   "$LOG_DIR/map.log"   "$RUN_DIR/map.pid"
    [[ -x "$WEB" ]] && start_one "web-server" "$WEB" "$LOG_DIR/web.log" "$RUN_DIR/web.pid"
    [[ -x "$TOOL" ]] && start_one "tool-server" "$TOOL" "$LOG_DIR/tool.log" "$RUN_DIR/tool.pid"
    ;;

  stop)
    echo "=== Parando Servidores rAthena ==="
    stop_one "tool-server"   "$RUN_DIR/tool.pid"
    stop_one "web-server"    "$RUN_DIR/web.pid"
    stop_one "map-server"    "$RUN_DIR/map.pid"
    stop_one "char-server"   "$RUN_DIR/char.pid"
    stop_one "login-server"  "$RUN_DIR/login.pid"
    ;;

  restart)
    echo "=== Reiniciando Servidores rAthena ==="
    "$0" stop
    sleep 1
    "$0" start
    ;;

  status)
    echo "=== Status dos Servidores rAthena ==="
    for svc in login char map web tool; do
      pidf="$RUN_DIR/${svc}.pid"
      pid="$(get_pid "$pidf")"
      if is_running "$pid"; then
        uptime=$(ps -p "$pid" -o etime= | tr -d ' ')
        echo "[OK]   ${svc}-server rodando (PID $pid | Uptime: $uptime)"
      else
        echo "[FAIL] ${svc}-server parado"
      fi
    done
    ;;

  monitor)
    monitor
    ;;

  autorestart)
    auto_recover
    ;;

  tail)
    echo "=== Logs rAthena (Ctrl+C para sair) ==="
    tail -n 50 -f "$LOG_DIR/"*.log
    ;;

  *)
    echo "Uso: $0 {start|stop|restart|status|monitor|autorestart|tail}"
    exit 2
    ;;
esac
