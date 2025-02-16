import Foundation
import LivenKit

final class Scale: ObservableObject {
    typealias CurveType = LivenProto.Scale.CurveType
    typealias ScalePos = LivenProto.Scale.ScalePos

    @Published public var lCurve: CurveType
    @Published public var rCurve: CurveType
    @Published public var scalePos: ScalePos
    @Published public var lGain: Int8
    @Published public var rGain: Int8

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
        lGain = s.lGain
        rGain = s.rGain
    }
}

extension Scale: LivenEncodable {
    func convertToLiven() -> LivenProto.Scale {
        .init(
            lGain: lGain,
            rGain: rGain,
            lCurve: lCurve,
            rCurve: rCurve,
            scalePos: scalePos
        )
    }
}
