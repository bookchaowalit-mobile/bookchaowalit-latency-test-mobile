# Latency Test — Mobile

SwiftUI app for **Latency Test** — measure round-trip time to a URL.

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s 101 Portfolio Projects.

## Status

This is a Swift package, not yet a shippable app:

- `Sources/LatencyTestCore` — Foundation-only domain logic, unit-tested in
  `Tests/LatencyTestCoreTests` (XCTest).
- `Sources/LatencyTestUI` — SwiftUI tab shell (Home / Explore / Profile). It does not
  use `LatencyTestCore` yet, and there is no Xcode app target (`@main`) yet.

The code has **not been compiled outside CI** (it was written without a Swift
toolchain); the macOS CI job is the first real build. See
[docs/UPGRADE-PLAN.md](docs/UPGRADE-PLAN.md).

## Core features (`LatencyTestCore`)

- Target normalisation: bare hosts get `https://`; only http(s) accepted
- Rolling log of the last 12 readings (same as the web app)
- Stats over successful readings only: average, median, min, max, jitter; failures counted separately
- Latency grade buckets (Excellent / Good / Fair / Poor)

## Tech Stack

- **UI:** SwiftUI (iOS 17+ / macOS 14+)
- **Language:** Swift 5.10
- **Tests:** XCTest via SwiftPM

## Getting Started

```bash
swift build
swift test          # runs LatencyTestCoreTests
open Package.swift  # opens in Xcode 15+
```

CI (`.github/workflows/build.yml`, macOS 14) runs `swift build` and
`swift test`; failures fail the workflow.

## Related

- **Frontend:** [bookchaowalit-website/latency-test-frontend](https://github.com/bookchaowalit-website/bookchaowalit-latency-test-frontend)
- **Portfolio:** [bookchaowalit.com](https://bookchaowalit.com)

## License

MIT
