#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-217577-217587/upstdc_backend"
cd "$WORKSPACE"
export MAVEN_OPTS="-Xmx512m"
# Build
mvn -q -B package -DskipTests || { echo "Build failed" >&2; exit 6; }
# find jar
JAR=$(printf '%s\n' target/app.jar target/*.jar 2>/dev/null | head -n1 || true)
if [ -z "$JAR" ]; then echo "No jar produced" >&2; exit 7; fi
# start app
LOGFILE=$(mktemp /tmp/upstdc_app.XXXXXX.log)
SPRING_DATASOURCE_URL="jdbc:h2:mem:upstdc;DB_CLOSE_DELAY=-1"
JAVA_OPTS="-Djava.awt.headless=true -Xmx512m"
SPRING_PROFILES_ACTIVE=dev SPRING_DATASOURCE_URL="$SPRING_DATASOURCE_URL" java $JAVA_OPTS -jar "$JAR" >"$LOGFILE" 2>&1 &
PID=$!
# store references
echo "$PID" >/tmp/upstdc_app.pid
echo "$LOGFILE" >/tmp/upstdc_app.logpath
# Wait for startup (timeout 60s)
MAX=60
SUCCESS=0
for i in $(seq 1 $MAX); do
  sleep 1
  if curl -sS --fail --connect-timeout 2 http://127.0.0.1:8080/health -o /tmp/upstdc_health.json 2>/dev/null; then
    if grep -q '"status"' /tmp/upstdc_health.json && grep -q 'UP' /tmp/upstdc_health.json; then
      echo "health: OK"
      SUCCESS=1
      break
    fi
  fi
  if ! kill -0 "$PID" 2>/dev/null; then
    echo "Process died; check log" >&2
    sed -n '1,200p' "$LOGFILE" >&2 || true
    rm -f /tmp/upstdc_health.json || true
    # cleanup
    rm -f /tmp/upstdc_app.pid /tmp/upstdc_app.logpath || true
    exit 8
  fi
  if [ "$i" -eq "$MAX" ]; then
    echo "Timeout waiting for health" >&2
    sed -n '1,200p' "$LOGFILE" >&2 || true
    kill "$PID" || true
    rm -f /tmp/upstdc_health.json || true
    rm -f /tmp/upstdc_app.pid /tmp/upstdc_app.logpath || true
    exit 9
  fi
done
# Evidence
cat /tmp/upstdc_health.json || true
sed -n '1,200p' "$LOGFILE" || true
# Clean stop
kill "$PID" || true
wait "$PID" 2>/dev/null || true
rm -f "$LOGFILE" /tmp/upstdc_health.json /tmp/upstdc_app.pid /tmp/upstdc_app.logpath || true
exit 0
