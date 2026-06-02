#!/usr/bin/env bash
# brainstorming visual companion - stop server
#
# NOTE: minimal reimplementation of the upstream stop-server.sh. It:
#   - Reads server.pid from $BRAINSTORM_DIR/state/
#   - Sends SIGTERM, falls back to SIGKILL after 2s
#   - Cleans pidfile and server-info
#
# Canonical upstream version (full feature parity):
#   https://github.com/obra/superpowers/blob/main/skills/brainstorming/scripts/stop-server.sh

set -euo pipefail

SESSION_DIR="${BRAINSTORM_DIR:-/tmp/brainstorm}"
STATE_DIR="$SESSION_DIR/state"
PIDFILE="$STATE_DIR/server.pid"

if [ ! -f "$PIDFILE" ]; then
  echo "No pidfile at $PIDFILE — server already stopped." >&2
  exit 0
fi

PID="$(cat "$PIDFILE")"

if ! kill -0 "$PID" 2>/dev/null; then
  echo "Process $PID not running." >&2
  rm -f "$PIDFILE" "$STATE_DIR/server-info"
  exit 0
fi

kill -TERM "$PID" 2>/dev/null || true

# Wait up to 2s for graceful shutdown
for _ in $(seq 1 20); do
  if ! kill -0 "$PID" 2>/dev/null; then
    break
  fi
  sleep 0.1
done

# Force kill if still alive
if kill -0 "$PID" 2>/dev/null; then
  kill -KILL "$PID" 2>/dev/null || true
fi

rm -f "$PIDFILE" "$STATE_DIR/server-info"
echo "Server stopped (pid $PID)."
