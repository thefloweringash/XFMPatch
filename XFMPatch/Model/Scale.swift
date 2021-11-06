import Foundation

final class Scale: ObservableObject {
    typealias CurveType = LivenProto.TPDT.Scale.CurveType

    @Published public var lCurve: CurveType
    @Published public var rCurve: CurveType
    @Published public var scalePos: UInt8
    @Published public var lGain: Float
    @Published public var rGain: Float

    public init() {
        lCurve = .Linear
        rCurve = .Linear
        scalePos = 3
        lGain = 0
        rGain = 0
    }
}

extension Scale: LivenReceiverDecodable {
    func updateFrom(liven s: LivenProto.TPDT.Scale) {
        lCurve = s.lCurve
        rCurve = s.rCurve
        scalePos = s.scalePos
        lGain = Float(s.lGain)
        rGain = Float(s.rGain)
    }

    typealias LivenReceiverType = LivenProto.TPDT.Scale
}
