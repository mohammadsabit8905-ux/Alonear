
import Foundation

/// Automation data for Alonear's stereo panning sequencer.
public struct PanningProgram {

    public struct Point: Equatable, Sendable {
        /// Position within the loop, from 0.0 to 1.0.
        public var position: Float

        /// Pan value: -1.0 = left, 0.0 = center, +1.0 = right.
        public var pan: Float

        public init(position: Float, pan: Float) {
            self.position = min(max(position, 0.0), 1.0)
            self.pan = min(max(pan, -1.0), 1.0)
        }
    }

    public static let maximumPoints = 64

    public private(set) var points: [Point] = []

    public init() {}

    /// Replaces the automation points, keeping at most 64.
    public mutating func setPoints(_ newPoints: [Point]) {
        points = Array(
            newPoints
                .sorted { $0.position < $1.position }
                .prefix(Self.maximumPoints)
        )
    }

    /// Adds or replaces a point at approximately the same position.
    public mutating func addPoint(_ point: Point) {
        let tolerance: Float = 0.0001

        if let index = points.firstIndex(
            where: { abs($0.position - point.position) < tolerance }
        ) {
            points[index] = point
        } else if points.count < Self.maximumPoints {
            points.append(point)
        } else {
            return
        }

        points.sort { $0.position < $1.position }
    }

    /// Removes the point nearest to the supplied loop position.
    public mutating func removePoint(at position: Float) {
        guard !points.isEmpty else { return }

        let target = min(max(position, 0.0), 1.0)

        guard let index = points.indices.min(by: {
            abs(points[$0].position - target)
                < abs(points[$1].position - target)
        }) else {
            return
        }

        points.remove(at: index)
    }

    /// Returns the interpolated pan value at a loop position.
    public func pan(at position: Float) -> Float {
        guard !points.isEmpty else { return 0.0 }

        let target = min(max(position, 0.0), 1.0)

        guard let first = points.first,
              let last = points.last else {
            return 0.0
        }

        if target <= first.position {
            return first.pan
        }

        if target >= last.position {
            return last.pan
        }

        for index in 0..<(points.count - 1) {
            let start = points[index]
            let end = points[index + 1]

            if target >= start.position && target <= end.position {
                let distance = end.position - start.position

                guard distance > 0.0 else {
                    return end.pan
                }

                let progress = (target - start.position) / distance

                return start.pan + (end.pan - start.pan) * progress
            }
        }

        return 0.0
    }

    public mutating func clear() {
        points.removeAll()
    }
}
