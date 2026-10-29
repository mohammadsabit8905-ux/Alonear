
import Foundation

/// Alonear's basic stereo audio processor.
/// Pan range: -1.0 = left, 0.0 = center, +1.0 = right.
public struct StereoProcessor {

    public init() {}

    /// Processes stereo samples in place.
    ///
    /// - Parameters:
    ///   - left: Left-channel audio samples.
    ///   - right: Right-channel audio samples.
    ///   - pan: Stereo pan position from -1 to +1.
    ///   - gain: Output gain, where 1.0 is unity gain.
    public func process(
        left: inout [Float],
        right: inout [Float],
        pan: Float = 0.0,
        gain: Float = 1.0
    ) {
        let sampleCount = min(left.count, right.count)

        guard sampleCount > 0 else { return }

        let position = min(max(pan, -1.0), 1.0)
        let outputGain = max(gain, 0.0)

        // Center preserves the original stereo signal.
        // Moving toward one side attenuates the opposite channel.
        let leftPanGain: Float =
            position > 0.0 ? 1.0 - position : 1.0

        let rightPanGain: Float =
            position < 0.0 ? 1.0 + position : 1.0

        for index in 0..<sampleCount {
            left[index] *= leftPanGain * outputGain
            right[index] *= rightPanGain * outputGain
        }
    }

    /// Resets no persistent state in this basic processor.
    public mutating func reset() {
        // Reserved for future DSP state.
    }
}
