# Upgrade plan

## Current state

Score: 3/10 (was 1/10) — domain logic + XCTest suite and honest CI exist, but
nothing has been compiled yet (no Swift toolchain was available when this was
written) and the UI is still a placeholder.

## Backlog

- P0: Confirm the macOS CI job is green (`swift build` + `swift test`); fix any
  compile errors it reports first.
- P0: Add an Xcode app target (`@main`) that hosts `LatencyTestUI`, and build screens on
  top of `LatencyTestCore` (an `@Observable` model wrapping the core API).
- P1: Probe with `URLSession` (HEAD, 10 s timeout, `URLSessionTaskMetrics` for DNS/connect/TLS breakdown) behind a protocol so it can be faked in tests.
- P1: Explain in the UI that this is HTTP round-trip time, not ICMP ping.
- P2: Add a Linux CI job that runs `swift test --filter LatencyTestCoreTests` after
  making the UI target conditional, to keep the core portable.

## Done in this pass

- Split the package into `LatencyTestCore` (Foundation-only logic), `LatencyTestUI` (existing
  SwiftUI shell) and `LatencyTestCoreTests` (6 XCTest cases).
- Removed `@main` from the library target (it belongs in an app target).
- CI: removed `|| echo` / `|| true` so build and test failures are visible.
- README now states what is verified and what is not.
- New Swift sources were syntax-checked with tree-sitter-swift only.
