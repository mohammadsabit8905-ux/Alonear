
import XCTest
@testable import AlonearDSP

final class PanningProgramTests: XCTestCase {

    func testEmptyProgramReturnsCenter() {
        let program = PanningProgram()
        XCTAssertEqual(program.pan(at: 0.5), 0.0)
    }

    func testPanInterpolatesBetweenPoints() {
        var program = PanningProgram()

        program.setPoints([
            .init(position: 0.0, pan: -1.0),
            .init(position: 1.0, pan: 1.0)
        ])

        XCTAssertEqual(program.pan(at: 0.5), 0.0, accuracy: 0.0001)
    }

    func testPanClampsToPointRange() {
        var program = PanningProgram()

        program.setPoints([
            .init(position: 0.25, pan: -0.5),
            .init(position: 0.75, pan: 0.5)
        ])

        XCTAssertEqual(program.pan(at: 0.0), -0.5)
        XCTAssertEqual(program.pan(at: 1.0), 0.5)
    }

    func testPointsAreSorted() {
        var program = PanningProgram()

        program.setPoints([
            .init(position: 1.0, pan: 1.0),
            .init(position: 0.0, pan: -1.0)
        ])

        XCTAssertEqual(program.points.first?.position, 0.0)
        XCTAssertEqual(program.points.last?.position, 1.0)
    }

    func testProgramAcceptsAtMost64Points() {
        var program = PanningProgram()

        let points = (0..<70).map { index in
            PanningProgram.Point(
                position: Float(index) / 69.0,
                pan: 0.0
            )
        }

        program.setPoints(points)

        XCTAssertEqual(program.points.count, 64)
    }

    func testClearRemovesAllPoints() {
        var program = PanningProgram()
        program.addPoint(.init(position: 0.5, pan: 1.0))

        program.clear()

        XCTAssertTrue(program.points.isEmpty)
        XCTAssertEqual(program.pan(at: 0.5), 0.0)
    }
}
