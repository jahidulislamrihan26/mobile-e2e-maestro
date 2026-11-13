# Mobile App Tests with Maestro

[![Android tests](https://github.com/jahidulislamrihan26/mobile-e2e-maestro/actions/workflows/android.yml/badge.svg)](https://github.com/jahidulislamrihan26/mobile-e2e-maestro/actions/workflows/android.yml)

End-to-end tests for a mobile shopping app, written with [Maestro](https://maestro.mobile.dev). They run on a real Android emulator in GitHub Actions, and every run is also tested for flakiness.

**The app:** My Demo App (React Native) by Sauce Labs. Browse products, fill a cart, log in, enter an address and card, place an order.

## What it shows

- **10 test flows**, each with a stable id (`TC-001` … `TC-010`): catalog, cart (add, change quantity, remove, two products), login errors, address and card validation, and a full purchase from catalog to order confirmation.
- **Smoke and regression suites** chosen with tags. `smoke` is the short set that proves the app is usable; `regression` holds the edge cases.
- **Reusable subflows.** Start clean, add to cart, log in, fill address, fill payment: written once, called by the tests with inputs.
- **A real emulator in CI.** Android 11 (API 30), hardware-accelerated, started on a GitHub-hosted runner. The JUnit report and Maestro's debug output (screenshots, UI trees) are uploaded with every run.
- **A flakiness measurement.** One workflow repeats a set of tests and reports each test's pass rate.
- **A negative control.** A flow that is wrong on purpose runs after the real suite and must fail. If it passes, the build fails, because that would mean the assertions check nothing.

## Results

| Measure | Result |
|---|---|
| Full suite (10 flows) on the emulator | 10 of 10 passed, about 5.5 minutes |
| Smoke flows repeated 10 times | 40 of 40 executions passed, no flaky test |
| Negative control (wrong total on purpose) | Fails as it must |

The flakiness numbers come from the [Flakiness check](.github/workflows/flakiness.yml) workflow (run it yourself from the Actions tab and choose how many repetitions). 40 passes in a row is encouraging, not proof of zero flakiness; a larger run would say more.

## The tests

| Id | Behaviour | Tags |
|---|---|---|
| TC-001 | Catalog lists the products with their prices | smoke, catalog |
| TC-002 | Product page shows the product and an Add To Cart button | smoke, catalog |
| TC-003 | Adding a product puts it in the cart with the right total | smoke, cart |
| TC-004 | Changing the quantity updates the total | regression, cart |
| TC-005 | Removing the only item empties the cart | regression, cart |
| TC-006 | Two different products add up in the cart | regression, cart |
| TC-007 | Login rejects an empty form, a wrong password and a locked-out user | regression, login |
| TC-008 | Checkout will not go past an empty shipping address | regression, checkout |
| TC-009 | A customer can buy a product from catalog to confirmation | smoke, checkout |
| TC-010 | Payment step rejects an invalid card number | regression, checkout |

## Run it

Tests run in CI on every push; you can also trigger them from the Actions tab and pick a tag.

On your own machine you need Java 17, the Android SDK with an emulator or a phone connected, and Maestro:

```bash
bash scripts/install-maestro.sh
bash scripts/download-app.sh android      # downloads the app from its official release
bash scripts/run-tests.sh                 # all flows
TAGS=smoke bash scripts/run-tests.sh      # only the smoke flows
```

## Layout

```
flows/              the tests (one behaviour each)
subflows/           reusable steps the tests call
negative-control/   a flow that must fail
probe/              small steps used to map the app's screens (see below)
scripts/            install Maestro, download the app, run tests, measure flakiness
docs/               test strategy, conventions and the flaky-test policy
.github/workflows/  android.yml (tests), flakiness.yml (repeat runs), explore.yml (screen mapping)
```

## How it was built

The flows are not guesses about the screens. `explore.yml` walks through the app on an emulator and saves each screen's UI tree, and the flows use the labels found there. Doing it that way showed things a screenshot would not have: the form labels contain a literal `*` (a regex symbol in Maestro selectors), the app's header buttons are named for accessibility rather than shown as text, and `hideKeyboard` sends the Back key on an emulator with no keyboard. Those are written down in [docs/conventions.md](docs/conventions.md).

- [Test strategy](docs/test-strategy.md): what is tested, in what order of risk, what is not.
- [Conventions](docs/conventions.md): selectors, tags, waiting, flaky-test policy.

## Not done

- **iOS.** The flows rely on accessibility labels that React Native also sets on iOS, so they are expected to carry over, but I have not run them on a simulator and do not claim it.
- **Real devices or a device cloud.** Emulator only.
- **Visual checks.** Maestro verifies what is on screen, not how it looks.

The app is downloaded at run time and is not stored here. It is published by Sauce Labs for demos and testing; it is not mine.
