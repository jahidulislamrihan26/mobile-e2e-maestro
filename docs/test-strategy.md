# Test strategy

## What is tested, and why this app

The app under test is **My Demo App** (React Native), published by Sauce Labs for demos and testing. It is a small shop: browse products, fill a cart, log in, enter an address and a card, place an order. That is the same journey a real mobile shop has, and it is where a mobile shop loses money when it breaks, so the suite is built around it.

The app is downloaded from its official release when a test run starts. It is not stored in this repository.

## Risk first

| Area | Why it matters | Tests |
|---|---|---|
| Buying something | The whole point of the app. If this breaks, nothing else matters. | TC-009 (full purchase) |
| Money on screen | A wrong total is a wrong charge. | TC-003, TC-004, TC-006, TC-009 (total with shipping) |
| Bad input at checkout | Bad addresses and cards must be stopped before an order is placed. | TC-008, TC-010 |
| Login | Checkout needs an account. Wrong passwords and locked accounts must be refused clearly. | TC-007 |
| Cart editing | People change their mind: quantity, removing items. | TC-004, TC-005, TC-006 |
| Browsing | The catalog has to load with the right products and prices. | TC-001, TC-002 |

## Two suites

- **smoke** (TC-001, 002, 003, 009): the shortest path that proves the app is usable. Run on every change. If smoke fails, stop and look.
- **regression** (the rest): edge cases and validation. Run before a release and on a schedule.

A flow can carry more than one tag (for example `smoke` and `checkout`), so you can also run one area: `TAGS=cart bash scripts/run-tests.sh`.

## What is deliberately not tested

- **Visual layout.** Maestro checks what is on the screen, not how it looks. Pixel comparison belongs in a screenshot tool.
- **Device features** (camera/QR scanner, location, fingerprint, drawing). They are in the menu, but they depend on hardware an emulator only pretends to have.
- **The real payment.** The app takes any valid-looking card and shows the confirmation. There is no payment service behind it to test.

## Where tests run

| Where | How | Status |
|---|---|---|
| Android emulator, GitHub Actions | `android.yml` (API 30, x86_64, hardware-accelerated) | Running |
| Real devices / cloud device farm | Same flows, different target | Not set up |
| iOS simulator | Same flows, macOS runner | Not set up yet |

The flows were written against the Android build. Selectors rely on the app's accessibility labels, which React Native also sets on iOS, so the flows are expected to carry over. That has not been checked on iOS and is not claimed.

## Test data

One standard user (`bob@example.com`) and one locked-out user (`alice@example.com`) ship with the demo app and are listed on its login screen. Test cards use well-known test numbers (`4111 1111 1111 1111` passes the card checksum; `4111 1111 1111 1112` fails it). No real accounts, cards or personal data are used.

Every test starts with `launchApp: clearState`, so tests do not depend on each other and can run in any order.
