#!/usr/bin/env bash
# Use strict mode and ensure we don't trip on $! or unset vars inadvertently
set -euo pipefail

WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-217577-217587/upstdc_backend"
cd "$WORKSPACE"

export MAVEN_OPTS="${MAVEN_OPTS:-"-Xmx512m"}"

# discover jar robustly; avoid globbing failures tripping -e/-u
JAR="$( (printf '%s\n' target/app.jar 2>/dev/null; ls -1 target/*.jar 2>/dev/null | head -n1) | head -n1 || true )"
if [ -z "${JAR:-}" ] || [ ! -f "$JAR" ]; then
  echo "No jar to run (expected in target/). Did you run build.sh?" >&2
  exit 7
fi

LOGFILE="$(mktemp /tmp/upstdc_app.XXXXXX.log)"

# Prepare runtime env: in-memory H2 and dev profile, headless + bounded memory
SPRING_DATASOURCE_URL="jdbc:h2:mem:upstdc;DB_CLOSE_DELAY=-1"
JAVA_OPTS="-Djava.awt.headless=true -Xmx512m"

# Start the app in background capturing PID safely under strict mode.
# We temporarily disable -u only around $! expansion to avoid 'unbound variable' edge-cases.
set +u
SPRING_PROFILES_ACTIVE=dev SPRING_DATASOURCE_URL="$SPRING_DATASOURCE_URL" \
  java $JAVA_OPTS -jar "$JAR" >"$LOGFILE" 2>&1 &
PID=$!
set -u

# Validate PID captured
if [ -z "${PID:-}" ] || ! kill -0 "$PID" 2>/dev/null; then
  echo "Failed to start application or capture PID. See log: $LOGFILE" >&2
  # Print last lines to aid debugging in CI logs
  tail -n 100 "$LOGFILE" >&2 || true
  exit 8
fi

# Persist PID and logfile path for other tools
printf "%s\n" "$PID" > /tmp/upstdc_app.pid
printf "%s\n" "$LOGFILE" > /tmp/upstdc_app.logpath
printf "started %s %s\n" "$PID" "$LOGFILE"
