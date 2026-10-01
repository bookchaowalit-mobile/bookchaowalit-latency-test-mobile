import Foundation

public enum TargetError: Error, Equatable {
    case empty
    case unsupportedScheme(String)
    case invalid(String)
}

/// Normalises what the user typed into a URL to probe.
/// Bare hosts ("example.com") get `https://`; only http(s) is accepted.
public func normalizeTarget(_ raw: String) throws -> URL {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { throw TargetError.empty }
    let candidate: String
    if let range = trimmed.range(of: "://") {
        let scheme = trimmed[trimmed.startIndex..<range.lowerBound].lowercased()
        guard scheme == "http" || scheme == "https" else { throw TargetError.unsupportedScheme(scheme) }
        candidate = trimmed
    } else {
        candidate = "https://" + trimmed
    }
    guard let url = URL(string: candidate), let host = url.host, !host.isEmpty, !host.contains(" ") else {
        throw TargetError.invalid(trimmed)
    }
    return url
}

/// One probe result. `milliseconds` is nil when the request failed.
public struct Reading: Equatable {
    public let milliseconds: Double?
    public let error: String?

    public static func success(_ ms: Double) -> Reading { Reading(milliseconds: ms, error: nil) }
    public static func failure(_ message: String) -> Reading { Reading(milliseconds: nil, error: message) }

    public var isSuccess: Bool { milliseconds != nil }
}

public struct LatencyStats: Equatable {
    public let count: Int
    public let failures: Int
    public let average: Double
    public let median: Double
    public let min: Double
    public let max: Double
    /// Mean absolute difference between consecutive successful readings.
    public let jitter: Double
}

/// Keeps the most recent readings (12 by default, matching the web app).
public struct ReadingLog {
    public private(set) var readings: [Reading] = []
    public let capacity: Int

    public init(capacity: Int = 12) {
        precondition(capacity > 0, "capacity must be positive")
        self.capacity = capacity
    }

    public mutating func append(_ reading: Reading) {
        readings.append(reading)
        if readings.count > capacity { readings.removeFirst(readings.count - capacity) }
    }

    public mutating func clear() { readings.removeAll() }

    /// Statistics over successful readings; failures are counted but excluded
    /// from timing. Returns nil when there is no successful reading.
    public var stats: LatencyStats? {
        let values = readings.compactMap(\.milliseconds)
        guard !values.isEmpty else { return nil }
        let sorted = values.sorted()
        let mid = sorted.count / 2
        let median = sorted.count % 2 == 0 ? (sorted[mid - 1] + sorted[mid]) / 2 : sorted[mid]
        var jitter = 0.0
        if values.count > 1 {
            var total = 0.0
            for i in 1..<values.count { total += abs(values[i] - values[i - 1]) }
            jitter = total / Double(values.count - 1)
        }
        return LatencyStats(
            count: values.count,
            failures: readings.count - values.count,
            average: values.reduce(0, +) / Double(values.count),
            median: median,
            min: sorted.first!,
            max: sorted.last!,
            jitter: jitter
        )
    }
}

public enum LatencyGrade: String {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"

    /// Rough buckets for a round trip that includes DNS/TLS setup.
    public init(milliseconds: Double) {
        switch milliseconds {
        case ..<100: self = .excellent
        case ..<250: self = .good
        case ..<600: self = .fair
        default: self = .poor
        }
    }
}
