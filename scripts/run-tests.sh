#!/usr/bin/env bash
# Runs the Maestro flows on the device that is already booted (an emulator in CI, or a phone/emulator you started yourself).
#   bash scripts/run-tests.sh                 -> every flow
#   TAGS=smoke bash scripts/run-tests.sh      -> only the flows tagged "smoke"
# Writes a JUnit report and Maestro's own debug output (screenshots, UI trees, logs of failed steps) to reports/.
set +e
export PATH="$HOME/maestro/bin:$PATH"
REPORT_NAME="${REPORT_NAME:-android}"

adb install -r app/app.apk
mkdir -p reports
sleep "${SETTLE_SECONDS:-45}"   # let a freshly booted emulator settle before the first test

args=(test flows --format junit --output "reports/${REPORT_NAME}.xml" --test-output-dir "reports/${REPORT_NAME}-debug")
if [ -n "${TAGS:-}" ]; then args+=(--include-tags "$TAGS"); fi

maestro "${args[@]}"
code=$?
echo "maestro exit code: $code"

# Negative control: a flow that is wrong on purpose must fail. If it passes, the assertions are not checking anything.
if [ -z "${TAGS:-}" ] && [ "${SKIP_NEGATIVE_CONTROL:-0}" != "1" ]; then
  maestro test negative-control/wrong-total.yaml > reports/negative-control.log 2>&1
  if [ $? -eq 0 ]; then
    echo "NEGATIVE CONTROL PASSED, which it must not: the tests cannot fail."
    code=1
  else
    echo "Negative control failed as expected: the assertions do catch a wrong value."
  fi
fi
exit $code
