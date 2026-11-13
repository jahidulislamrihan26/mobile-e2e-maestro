#!/usr/bin/env bash
# Downloads the app under test from its official release. The app is not copied into this repository: it is published by Sauce Labs
# for demos and testing (github.com/saucelabs/my-demo-app-rn), and has no licence that allows redistributing it.
#   bash scripts/download-app.sh android     ->  app/app.apk
#   bash scripts/download-app.sh ios         ->  app/MyRNDemoApp.app  (a build for the iOS simulator)
set -euo pipefail
BASE="https://github.com/saucelabs/my-demo-app-rn/releases/download/v1.3.0"
mkdir -p app
case "${1:-android}" in
  android) curl -fsSL -o app/app.apk "$BASE/Android-MyDemoAppRN.1.3.0.build-244.apk"; ls -l app/app.apk ;;
  ios) curl -fsSL -o app/sim.zip "$BASE/iOS-Simulator-MyRNDemoApp.1.3.0-162.zip"; unzip -q -o app/sim.zip -d app; ls app ;;
  *) echo "usage: download-app.sh android|ios" >&2; exit 2 ;;
esac
