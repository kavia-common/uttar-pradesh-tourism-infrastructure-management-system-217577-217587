#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-217577-217587/upstdc_backend"
cd "$WORKSPACE"
export MAVEN_OPTS="-Xmx512m"
# Build executable jar
mvn -q -B package -DskipTests || { echo "Build failed" >&2; exit 6; }
# ensure jar exists
JAR=$(printf '%s\n' target/app.jar target/*.jar 2>/dev/null | head -n1 || true)
if [ -z "$JAR" ]; then echo "No jar produced" >&2; exit 7; fi
printf "%s\n" "$JAR"
