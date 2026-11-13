#!/usr/bin/env bash
# Installs a pinned Maestro CLI from the official GitHub release, so every run uses the same version.
#   MAESTRO_VERSION=2.12.1 bash scripts/install-maestro.sh        then:  export PATH="$HOME/maestro/bin:$PATH"
set -euo pipefail
VERSION="${MAESTRO_VERSION:-2.12.1}"
DIR="${MAESTRO_DIR:-$HOME/maestro-install}"
mkdir -p "$DIR"
curl -fsSL -o "$DIR/maestro.zip" "https://github.com/mobile-dev-inc/maestro/releases/download/cli-${VERSION}/maestro.zip"
unzip -q -o "$DIR/maestro.zip" -d "$DIR"
mkdir -p "$HOME/maestro"
rm -rf "$HOME/maestro/bin" "$HOME/maestro/lib"
cp -r "$DIR/maestro/bin" "$DIR/maestro/lib" "$HOME/maestro/"
echo "Maestro ${VERSION} installed in $HOME/maestro/bin"
