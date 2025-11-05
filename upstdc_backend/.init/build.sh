#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-217577-217587/upstdc_backend"
cd "$WORKSPACE"

export MAVEN_OPTS="${MAVEN_OPTS:-"-Xmx512m"}"

# Build executable jar in batch/quiet mode
if ! mvn -q -B package -DskipTests; then
  echo "Build failed" >&2
  exit 6
fi

# ensure jar exists; avoid glob failing when no file matches
JAR="$( (printf '%s\n' target/app.jar 2>/dev/null; ls -1 target/*.jar 2>/dev/null | head -n1) | head -n1 || true )"
if [ -z "${JAR:-}" ] || [ ! -f "$JAR" ]; then
  echo "No jar produced in target/" >&2
  exit 7
fi

printf "%s\n" "$JAR"
