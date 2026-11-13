# Conventions

## Selectors: how a test finds something on screen

In order of preference:

1. **The app's accessibility label**, e.g. `Login button`, `Username input field`, `cart badge`. These are set for assistive technology and for testing, they do not change when the text is translated or reworded, and they are the same on Android and iOS (React Native).
2. **Visible text**, e.g. `Proceed To Checkout`. Fine for things a user reads, and it is what an assertion should check ("the user sees the error").
3. **Position or index.** Avoided. It breaks when the layout changes.

Maestro treats the text in a selector as a **regular expression**, which causes two traps the flows already handle:

- `$` means "end of line", so prices are written `"\\$29.99"`.
- `*` means "repeat", and this app's form labels contain a literal asterisk (`Full Name* input field`), so those are matched with `"Full Name.*input field"`.

## One flow, one behaviour

Each file in `flows/` is one test case with a stable id in its name (`TC-009 A customer can buy…`). A test checks one behaviour. When a step is needed by many tests (start clean, log in, fill the address), it lives once in `subflows/` and the tests call it with `runFlow`, passing inputs through `env`. If the app changes its login screen, one file changes.

Subflows are not tests, so they sit outside `flows/` and `flows/config.yaml` only picks up `*.yaml` in that folder.

## Tags

| Tag | Meaning |
|---|---|
| `smoke` | The shortest set that proves the app is usable |
| `regression` | Edge cases and validation |
| `catalog`, `cart`, `login`, `checkout` | The area a test belongs to |

## Waiting

No fixed `sleep` in the flows. Maestro waits for an element to appear before it acts, and `scrollUntilVisible` scrolls to a button that is below the fold. A fixed sleep is either too short (flaky) or too long (slow).

The one wait outside Maestro is a 45-second pause in `scripts/run-tests.sh` after the emulator boots. A freshly started emulator is busy for a while, and starting right away showed Android's "Process system isn't responding" dialog over the app. `subflows/start-app.yaml` also dismisses that dialog if it still appears.

## Things that look harmless and are not

- **`hideKeyboard` on Android** sends the Back key when no keyboard is showing. On this emulator that left the login screen and made the next step fail. The flows do not use it; the fields are not covered by a keyboard on this device image.
- **Assertions that match too much.** `assertVisible: "Login"` is true on the login screen, but also true on any screen that says "Login" somewhere. Where it matters, the flows assert on something only the target screen has (`Enter a shipping address`).

## Flaky-test policy

A test that fails and then passes on a re-run, with no change to the app or the test, is **flaky**. Flaky tests are worse than missing tests: people learn to ignore red.

1. **Measure, don't guess.** `flakiness.yml` repeats a set of flows and reports each test's pass rate. See the numbers in the README.
2. **Don't hide it with retries.** A retry turns an intermittent failure into a green tick and keeps the cause. If a test is retried, that is recorded as a known issue with a reason, not left as the default.
3. **Find the cause.** The usual ones: waiting for the wrong thing, a shared state between tests, an overloaded emulator, a dialog covering the app.
4. **Quarantine if needed.** A test that cannot be fixed quickly gets a `quarantine` tag and is excluded from the gate, but still runs so it stays visible. It is fixed or deleted, not left there.
