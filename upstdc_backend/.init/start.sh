#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-217577-217587/upstdc_backend"
cd "$WORKSPACE"
export MAVEN_OPTS="-Xmx512m"
# discover jar
JAR=$(printf '%s\n' target/app.jar target/*.jar 2>/dev/null | head -n1 || true)
if [ -z "$JAR" ]; then echo "No jar to run" >&2; exit 7; fi
LOGFILE=$(mktemp /tmp/upstdc_app.XXXXXX.log)
# env inline: in-memory H2 and dev profile, headless + bounded memory
SPRING_DATASOURCE_URL="jdbc:h2:mem:upstdc;DB_CLOSE_DELAY=-1"
JAVA_OPTS="-Djava.awt.headless=true -Xmx512m"
SPRING_PROFILES_ACTIVE=dev SPRING_DATASOURCE_URL="$SPRING_DATASOURCE_URL" java $JAVA_OPTS -jar "$JAR" >"$LOGFILE" 2>&1 &
PID=$!
# return PID and logfile for other scripts
printf "%s\n" "$PID" > /tmp/upstdc_app.pid
printf "%s\n" "$LOGFILE" > /tmp/upstdc_app.logpath
printf "started %s %s\n" "$PID" "$LOGFILE"
