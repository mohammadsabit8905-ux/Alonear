
import XCTest
@testable import AlonearDSP

final class StereoProcessorTests: XCTestCase {

    func testCenterPanPreservesStereoSignal() {
        let processor = StereoProcessor()
        var left: [Float] = [0.5, -0.25, 0.75]
        var right: [Float] = [-0.5, 0.25, -0.75]

        processor.process(
            left: &left,
            right: &right,
            pan: 0.0,
            gain: 1.0
        )

        XCTAssertEqual(left, [0.5, -0.25, 0.75])
        XCTAssertEqual(right, [-0.5, 0.25, -0.75])
    }

    func testPanRightAttenuatesLeftChannel() {
        let processor = StereoProcessor()
        var left: [Float] = [1.0]
        var right: [Float] = [1.0]

        processor.process(
            left: &left,
            right: &right,
            pan: 0.5
        )

        XCTAssertEqual(left[0], 0.5, accuracy: 0.0001)
        XCTAssertEqual(right[0], 1.0, accuracy: 0.0001)
    }

    func testPanLeftAttenuatesRightChannel() {
        let processor = StereoProcessor()
        var left: [Float] = [1.0]
        var right: [Float] = [1.0]

        processor.process(
            left: &left,
            right: &right,
            pan: -0.5
        )

        XCTAssertEqual(left[0], 1.0, accuracy: 0.0001)
        XCTAssertEqual(right[0], 0.5, accuracy: 0.0001)
    }

    func testGainIsAppliedToBothChannels() {
        let processor = StereoProcessor()
        var left: [Float] = [0.8]
        var right: [Float] = [0.4]

        processor.process(
            left: &left,
            right: &right,
            pan: 0.0,
            gain: 0.5
        )

        XCTAssertEqual(left[0], 0.4, accuracy: 0.0001)
        XCTAssertEqual(right[0], 0.2, accuracy: 0.0001)
    }

    func testPanIsClamped() {
        let processor = StereoProcessor()
        var left: [Float] = [1.0]
        var right: [Float] = [1.0]

        processor.process(
            left: &left,
            right: &right,
            pan: 5.0
        )

        XCTAssertEqual(left[0], 0.0, accuracy: 0.0001)
        XCTAssertEqual(right[0], 1.0, accuracy: 0.0001)
    }

    func testEmptyBuffersDoNotCrash() {
        let processor = StereoProcessor()
        var left: [Float] = []
        var right: [Float] = []

        processor.process(
            left: &left,
            right: &right
        )

        XCTAssertTrue(left.isEmpty)
        XCTAssertTrue(right.isEmpty)
    }
}
