import Foundation
import LivenKit

final class Scale: ObservableObject {
    typealias CurveType = LivenProto.Scale.CurveType
    typealias ScalePos = LivenProto.Scale.ScalePos

    @Published public var lCurve: CurveType
    @Published public var rCurve: CurveType
    @Published public var scalePos: ScalePos
    @Published public var lGain: Float
    @Published public var rGain: Float

    public init() {
        lCurve = .Linear
        rCurve = .Linear
        scalePos = .C4
        lGain = 0
        rGain = 0
    }
}

extension Scale: LivenDecodable {
    typealias LivenDecodeType = LivenProto.Scale

    func updateFrom(liven s: LivenProto.Scale) {
        lCurve = s.lCurve
        rCurve = s.rCurve
        scalePos = s.scalePos
        lGain = Float(s.lGain)
        rGain = Float(s.rGain)
    }
}

extension Scale: LivenEncodable {
    func convertToLiven() -> LivenProto.Scale {
        return .init(
            lGain: Int8(self.lGain),
            rGain: Int8(self.rGain),
            lCurve: self.lCurve,
            rCurve: self.rCurve,
            scalePos: self.scalePos
        )
    }
}
