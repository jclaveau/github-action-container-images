# playwright layer — `ubuntu-{dood,dind}-playwright`

Adds [Playwright](https://playwright.dev) + browsers on top of the [pnpm](../pnpm/README.md) layer.

## What it adds
- **Playwright** (pinned by `PLAYWRIGHT_VERSION`) installed globally, with browsers via
  `playwright install --with-deps --only-shell`; `PLAYWRIGHT_BROWSERS_PATH` is set.

## What it implies
- Built for **both modes**: `ubuntu-dood-playwright` and `ubuntu-dind-playwright`.
- The **heaviest** layer (it bundles browsers).
- The version-pinned tag carries the Playwright minor (`…-pwX.Y`).
- This directory also holds the **Playwright test project** (`tests/`, `playwright.config.ts`) that CI
  runs against the built image.
