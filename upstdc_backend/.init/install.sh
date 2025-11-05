#!/usr/bin/env bash
set -euo pipefail
# Install JDK 17, Maven, ca-certificates and locales non-interactively and configure environment
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-infrastructure-management-system-217577-217587/upstdc_backend"
sudo apt-get update -q && sudo apt-get install -y -q openjdk-17-jdk maven ca-certificates locales curl
sudo locale-gen en_US.UTF-8 || true
sudo update-ca-certificates || true
JAVA_HOME=$(dirname $(dirname $(readlink -f $(command -v javac))))
cat <<'EOF' | sudo tee /etc/profile.d/upstdc_env.sh > /dev/null
export SPRING_PROFILES_ACTIVE=dev
export JAVA_HOME="${JAVA_HOME}"
export PATH="$JAVA_HOME/bin:$PATH"
EOF
export JAVA_HOME="$JAVA_HOME"
export PATH="$JAVA_HOME/bin:$PATH"
java -version
mvn -v
