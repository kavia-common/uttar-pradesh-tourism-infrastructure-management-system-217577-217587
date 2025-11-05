#!/usr/bin/env bash
# Use strict mode and ensure we don't trip on $! or unset vars inadvertently
set -euo pipefail

WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-217577-217587/upstdc_backend"
cd "$WORKSPACE"

# Defaults for potentially unset environment variables under -u
export MAVEN_OPTS="${MAVEN_OPTS:-"-Xmx512m"}"
SERVER_PORT="${SERVER_PORT:-3001}"
MANAGEMENT_SERVER_PORT="${MANAGEMENT_SERVER_PORT:-$SERVER_PORT}"
SPRING_PROFILES_ACTIVE="${SPRING_PROFILES_ACTIVE:-dev}"

# discover jar robustly; avoid globbing failures tripping -e/-u
JAR="$( (printf '%s\n' target/app.jar 2>/dev/null; ls -1 target/*.jar 2>/dev/null | head -n1) | head -n1 || true )"
if [ -z "${JAR:-}" ] || [ ! -f "$JAR" ]; then
  echo "No jar to run (expected in target/). Did you run .init/build.sh?" >&2
  exit 7
fi

LOGFILE="$(mktemp /tmp/upstdc_app.XXXXXX.log)"

# Prepare runtime env: in-memory H2 and dev profile, headless + bounded memory
SPRING_DATASOURCE_URL="${SPRING_DATASOURCE_URL:-jdbc:h2:mem:upstdc;DB_CLOSE_DELAY=-1}"
JAVA_OPTS="${JAVA_OPTS:--Djava.awt.headless=true -Xmx512m}"

# Start the app in background capturing PID safely under strict mode.
# We temporarily disable -u only around $! expansion to avoid 'unbound variable' edge-cases.
set +u
SPRING_PROFILES_ACTIVE="$SPRING_PROFILES_ACTIVE" \
SERVER_PORT="$SERVER_PORT" \
MANAGEMENT_SERVER_PORT="$MANAGEMENT_SERVER_PORT" \
SPRING_DATASOURCE_URL="$SPRING_DATASOURCE_URL" \
  java $JAVA_OPTS -jar "$JAR" >"$LOGFILE" 2>&1 &
PID=$!
set -u

# Fallback: if for any reason $! expansion did not occur, try to detect the job PID
if [ -z "${PID:-}" ]; then
  PID="$(jobs -pr || true)"
fi

# Validate PID captured
if [ -z "${PID:-}" ] || ! kill -0 "$PID" 2>/dev/null; then
  echo "Failed to start application or capture PID. See log: $LOGFILE" >&2
  # Print last lines to aid debugging in CI logs
  tail -n 200 "$LOGFILE" >&2 || true
  exit 8
fi

# Persist PID and logfile path for other tools
printf "%s\n" "$PID" > /tmp/upstdc_app.pid
printf "%s\n" "$LOGFILE" > /tmp/upstdc_app.logpath
printf "started %s %s\n" "$PID" "$LOGFILE"

# Readiness wait loop for port and actuator health to aid container orchestration
START_TS=$(date +%s)
READY_TIMEOUT="${READY_TIMEOUT:-90}" # seconds

echo "Waiting for backend readiness on port ${SERVER_PORT} (timeout: ${READY_TIMEOUT}s)..."
while true; do
  # If process died, emit logs and exit
  if ! kill -0 "$PID" 2>/dev/null; then
    echo "Application process exited prematurely. Recent logs:" >&2
    tail -n 200 "$LOGFILE" >&2 || true
    exit 9
  fi
  # Check TCP port
  if (echo > /dev/tcp/127.0.0.1/"$SERVER_PORT") >/dev/null 2>&1; then
    # Optionally query actuator health if curl available
    if command -v curl >/dev/null 2>&1; then
      if curl -fsS "http://127.0.0.1:${MANAGEMENT_SERVER_PORT}/actuator/health" >/dev/null 2>&1 || \
         curl -fsS "http://127.0.0.1:${SERVER_PORT}/actuator/health" >/dev/null 2>&1 || \
         curl -fsS "http://127.0.0.1:${SERVER_PORT}/health" >/dev/null 2>&1; then
        echo "Backend ready on port ${SERVER_PORT} (PID ${PID})."
        break
      fi
    else
      # If curl not present, consider port-open as ready
      echo "Backend port ${SERVER_PORT} is open (PID ${PID})."
      break
    fi
  fi
  # Timeout handling
  NOW=$(date +%s)
  if [ $((NOW - START_TS)) -ge "$READY_TIMEOUT" ]; then
    echo "Readiness timeout after ${READY_TIMEOUT}s. Recent logs:" >&2
    tail -n 200 "$LOGFILE" >&2 || true
    exit 10
  fi
  sleep 1
done
