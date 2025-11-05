#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-217577-217587/upstdc_backend"
cd "$WORKSPACE"
export MAVEN_OPTS="-Xmx512m"
mvn -q -B test || { echo "Tests failed" >&2; exit 5; }
exit 0
