import XCTest
@testable import LatencyTestCore

final class LatencyTests: XCTestCase {
    func testNormalizesBareHostsToHttps() throws {
        XCTAssertEqual(try normalizeTarget(" example.com ").absoluteString, "https://example.com")
        XCTAssertEqual(try normalizeTarget("http://example.com/health").absoluteString, "http://example.com/health")
        XCTAssertEqual(try normalizeTarget("HTTPS://Example.com").host?.lowercased(), "example.com")
    }

    func testRejectsBadTargets() {
        XCTAssertThrowsError(try normalizeTarget("   ")) { XCTAssertEqual($0 as? TargetError, .empty) }
        XCTAssertThrowsError(try normalizeTarget("ftp://example.com")) {
            XCTAssertEqual($0 as? TargetError, .unsupportedScheme("ftp"))
        }
        XCTAssertThrowsError(try normalizeTarget("javascript://alert(1)"))
    }

    func testStatsExcludeFailures() throws {
        var log = ReadingLog()
        log.append(.success(100))
        log.append(.failure("timeout"))
        log.append(.success(300))
        log.append(.success(200))
        let s = try XCTUnwrap(log.stats)
        XCTAssertEqual(s.count, 3)
        XCTAssertEqual(s.failures, 1)
        XCTAssertEqual(s.average, 200, accuracy: 0.0001)
        XCTAssertEqual(s.median, 200, accuracy: 0.0001)
        XCTAssertEqual(s.min, 100)
        XCTAssertEqual(s.max, 300)
        XCTAssertEqual(s.jitter, 150, accuracy: 0.0001) // |300-100| + |200-300| over 2
    }

    func testEvenCountMedianAndEmptyStats() throws {
        var log = ReadingLog()
        XCTAssertNil(log.stats)
        log.append(.failure("dns"))
        XCTAssertNil(log.stats)
        log.append(.success(10))
        log.append(.success(30))
        XCTAssertEqual(try XCTUnwrap(log.stats).median, 20, accuracy: 0.0001)
    }

    func testLogKeepsOnlyTheMostRecentReadings() {
        var log = ReadingLog(capacity: 3)
        for ms in [1.0, 2, 3, 4, 5] { log.append(.success(ms)) }
        XCTAssertEqual(log.readings.compactMap(\.milliseconds), [3, 4, 5])
        log.clear()
        XCTAssertTrue(log.readings.isEmpty)
    }

    func testGrades() {
        XCTAssertEqual(LatencyGrade(milliseconds: 42), .excellent)
        XCTAssertEqual(LatencyGrade(milliseconds: 100), .good)
        XCTAssertEqual(LatencyGrade(milliseconds: 400), .fair)
        XCTAssertEqual(LatencyGrade(milliseconds: 2_000), .poor)
    }
}
