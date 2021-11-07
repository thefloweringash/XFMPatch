import Foundation
import LivenKit

final class Matrix: ObservableObject {
    @Published public var o1fb: Float = 0
    @Published public var o1r2: Float = 0
    @Published public var o1r3: Float = 0
    @Published public var o1r4: Float = 0

    @Published public var o2r1: Float = 0
    @Published public var o2fb: Float = 0
    @Published public var o2r3: Float = 0
    @Published public var o2r4: Float = 0

    @Published public var o3r1: Float = 0
    @Published public var o3r2: Float = 0
    @Published public var o3fb: Float = 0
    @Published public var o3r4: Float = 0

    @Published public var o4r1: Float = 0
    @Published public var o4r2: Float = 0
    @Published public var o4r3: Float = 0
    @Published public var o4fb: Float = 0

    @Published public var mr1: Float = 127
    @Published public var mr2: Float = 0
    @Published public var mr3: Float = 0
    @Published public var mr4: Float = 0

    init() {}

    private func clampFb(_ x: Float) -> Float {
        return min(64, max(-63, x))
    }

    private func clampR(_ x: Float) -> Float {
        return min(127, max(0, x))
    }
}


extension Matrix: LivenDecodable {
    typealias LivenDecodeType = LivenProto.Matrix

    func updateFrom(liven m: LivenProto.Matrix) {
        o1fb = Float(m.operatorLevels.0.0)
        o1r2 = Float(m.operatorLevels.0.1)
        o1r3 = Float(m.operatorLevels.0.2)
        o1r4 = Float(m.operatorLevels.0.3)

        o2r1 = Float(m.operatorLevels.1.0)
        o2fb = Float(m.operatorLevels.1.1)
        o2r3 = Float(m.operatorLevels.1.2)
        o2r4 = Float(m.operatorLevels.1.3)

        o3r1 = Float(m.operatorLevels.2.0)
        o3r2 = Float(m.operatorLevels.2.1)
        o3fb = Float(m.operatorLevels.2.2)
        o3r4 = Float(m.operatorLevels.2.3)

        o4r1 = Float(m.operatorLevels.3.0)
        o4r2 = Float(m.operatorLevels.3.1)
        o4r3 = Float(m.operatorLevels.3.2)
        o4fb = Float(m.operatorLevels.3.3)

        mr1 = Float(m.mixerLevels.0)
        mr2 = Float(m.mixerLevels.1)
        mr3 = Float(m.mixerLevels.2)
        mr4 = Float(m.mixerLevels.3)
    }
}

extension Matrix: LivenEncodable {
    typealias LivenEncodeType = LivenProto.Matrix

    func convertToLiven() -> LivenProto.Matrix {
        LivenProto.Matrix(
            operatorLevels: (
                (Int8(o1fb), UInt8(o1r2), UInt8(o1r3), UInt8(o1r4)),
                (UInt8(o2r1), Int8(o2fb), UInt8(o2r3), UInt8(o2r4)),
                (UInt8(o3r1), UInt8(o3r2), Int8(o3fb), UInt8(o3r4)),
                (UInt8(o4r1), UInt8(o4r2), UInt8(o4r3), Int8(o4fb))
            ),
            mixerLevels: (UInt8(mr1), UInt8(mr2), UInt8(mr3), UInt8(mr4))
        )
    }
}
