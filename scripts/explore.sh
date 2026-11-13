#!/usr/bin/env bash
# Walks through the app one small step at a time and, after each step, saves a screenshot and the screen's UI tree (as Maestro sees it).
# Used to write the real flows from facts about the screens instead of guesses. Runs on a booted emulator, with the app downloaded.
set +e
export PATH="$HOME/maestro/bin:$PATH"
adb install -r app/app.apk
mkdir -p artifacts
sleep 60   # let the freshly booted emulator settle; a busy system process is what causes "isn't responding" dialogs
for f in probe/*.yaml; do
  name=$(basename "$f" .yaml)
  echo "=== $name"
  maestro test scripts/dismiss-anr.yaml > /dev/null 2>&1
  maestro test "$f" 2>&1 | tail -n 12
  sleep 2
  maestro hierarchy > "artifacts/$name.json" 2> "artifacts/$name.err"
  adb exec-out screencap -p > "artifacts/$name.png"
done
echo "done"
