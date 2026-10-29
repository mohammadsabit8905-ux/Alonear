
import Foundation

/// Basic stereo processing for Alonear.
public struct StereoProcessor {
    public init() {}

    /// Applies fixed stereo panning and gain in place.
    public func process(
        left: inout [Float],
        right: inout [Float],
        pan: Float = 0.0,
        gain: Float = 1.0
    ) {
        let count = min(left.count, right.count)
        guard count > 0 else { return }

        let p = min(max(pan, -1.0), 1.0)
        let g = max(gain, 0.0)
        let leftGain = p > 0 ? 1.0 - p : 1.0
        let rightGain = p < 0 ? 1.0 + p : 1.0

        for i in 0..<count {
            left[i] *= leftGain * g
            right[i] *= rightGain * g
        }
    }

    /// Applies a looping panning automation program to a block.
    public func process(
        left: inout [Float],
        right: inout [Float],
        program: PanningProgram,
        startPosition: Float,
        positionIncrement: Float,
        gain: Float = 1.0
    ) {
        let count = min(left.count, right.count)
        guard count > 0 else { return }

        let g = max(gain, 0.0)

        for i in 0..<count {
            let raw = startPosition + Float(i) * positionIncrement
            var phase = raw.truncatingRemainder(dividingBy: 1.0)

            if phase < 0 {
                phase += 1.0
            }

            let p = program.pan(at: phase)
            let leftGain = p > 0 ? 1.0 - p : 1.0
            let rightGain = p < 0 ? 1.0 + p : 1.0

            left[i] *= leftGain * g
            right[i] *= rightGain * g
        }
    }

    public mutating func reset() {}

    func testAutomationMovesSoundAcrossStereoChannels() {
        var program = PanningProgram()
        program.setPoints([
            .init(position: 0.0, pan: -1.0),
            .init(position: 0.5, pan: 1.0),
            .init(position: 1.0, pan: -1.0)
        ])

        let processor = StereoProcessor()
        var left: [Float] = [1, 1, 1, 1]
        var right: [Float] = [1, 1, 1, 1]

        processor.process(
            left: &left,
            right: &right,
            program: program,
            startPosition: 0.0,
            positionIncrement: 0.25
        )

        XCTAssertEqual(left, [1, 1, 0, 1])
        XCTAssertEqual(right, [0, 1, 1, 1])
    }

    func testAutomationAppliesGain() {
        var program = PanningProgram()
        program.setPoints([
            .init(position: 0.0, pan: 0.0),
            .init(position: 1.0, pan: 0.0)
        ])

        let processor = StereoProcessor()
        var left: [Float] = [1, 0.5]
        var right: [Float] = [0.5, 1]

        processor.process(
            left: &left,
            right: &right,
            program: program,
            startPosition: 0.0,
            positionIncrement: 0.5,
            gain: 0.5
        )

        XCTAssertEqual(left, [0.5, 0.25])
        XCTAssertEqual(right, [0.25, 0.5])
    }
}
