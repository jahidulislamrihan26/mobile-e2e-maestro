#!/usr/bin/env bash
# Runs the same flows over and over on the booted device and keeps one JUnit report per run, to measure how often each test fails
# for no reason. Every test starts from a cleared app, so a run does not depend on the one before it.
#   RUNS=8 TAGS=smoke bash scripts/flakiness.sh
set +e
export PATH="$HOME/maestro/bin:$PATH"
RUNS="${RUNS:-8}"
TAGS="${TAGS:-smoke}"

adb install -r app/app.apk
mkdir -p reports/flaky
sleep "${SETTLE_SECONDS:-45}"

for i in $(seq 1 "$RUNS"); do
  echo "=== run $i of $RUNS"
  maestro test flows --include-tags "$TAGS" --format junit --output "reports/flaky/run-$i.xml" --test-output-dir "reports/flaky/run-$i-debug"
done
echo "finished $RUNS runs"
exit 0
