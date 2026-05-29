# playwright layer — `{ubuntu,alpine}-{dood,dind}-playwright`

Adds [Playwright](https://playwright.dev) + browsers on top of the [pnpm](../pnpm/README.md) layer.

## What it adds
- **Playwright** (pinned by `PLAYWRIGHT_VERSION`) installed globally.
  - **Ubuntu**: the bundled browsers via `playwright install --with-deps --only-shell`;
    `PLAYWRIGHT_BROWSERS_PATH` is set.
  - **Alpine**: **Chromium-only** via the system `chromium` package; `PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH`
    points at it and the browser download is skipped (see
    [Why Alpine is Chromium-only](#why-alpine-is-chromium-only)).

## Why Alpine is Chromium-only

Playwright doesn't drive off-the-shelf browsers — it builds and pins **patched** ones:
[Firefox](https://github.com/microsoft/playwright/tree/main/browser_patches/firefox) carries the
*Juggler* automation protocol and [WebKit](https://github.com/microsoft/playwright/tree/main/browser_patches/webkit)
is a patched build. Those are compiled against **glibc** and there are **no musl/Alpine builds**, so they
can't load on Alpine — and `playwright install --with-deps` runs `apt`, which doesn't exist there either.

Chromium is the exception: Playwright drives it over the stock **CDP** protocol, so it can point at the
distro's musl-native `chromium` package (`apk add chromium`) via `executablePath` — no patched build
needed. Hence Alpine tops out at Chromium.

Track whether this ever changes:
- [Playwright system requirements](https://playwright.dev/docs/intro#system-requirements) — the official
  supported-OS list. Today it's Debian / Ubuntu only; Alpine appearing here would mean musl builds exist.
- [microsoft/playwright#1986](https://github.com/microsoft/playwright/issues/1986) — the canonical
  "Alpine Linux Support" thread. A maintainer confirms there are no plans, and points at the remote
  `mcr.microsoft.com/playwright` browser container (connect over WebSocket) as the only cross-distro path.

## What it implies
- Built for **both modes and both OSes**: `ubuntu-dood-playwright`, `alpine-dind-playwright`, etc.
- **Slim — no compiler.** Built on the slim [`pnpm`](../pnpm/README.md) layer. If your tests' deps
  compile native addons, use the **`…-playwright-gyp`** twin (the same layer built on
  [`pnpm-gyp`](../pnpm-gyp/README.md)); its tag carries a `-gyp` suffix.
- The **heaviest** layer (Ubuntu bundles browsers; Alpine pulls system Chromium + fonts).
- The version-pinned tag carries the Playwright minor (`…-pwX.Y`).
- This directory also holds the **Playwright test project** (`tests/`, `playwright.config.ts`) that CI
  runs against the built image. The config auto-detects `PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH` and runs
  Chromium-only when it's set (Alpine).
