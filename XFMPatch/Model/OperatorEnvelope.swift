import Foundation
import LivenKit

final class OperatorEnvelope: ObservableObject {
    public let envelope: AmpEnvelope

    @Published public var timescale: Int
    @Published public var upCrv: Int
    @Published public var downCrv: Int

    convenience public init() {
        self.init(
            envelope: AmpEnvelope(l1: 127, t1: 0, l2: 127, t2: 0, l3: 127, t3: 0, l4: 0, t4: 0),
            timescale: 0,
            upCrv: 0,
            downCrv: 0
        )
    }

    public init(
        envelope: AmpEnvelope,
        timescale: Int,
        upCrv: Int,
        downCrv: Int
    ) {
        self.envelope = envelope
        self.timescale = timescale
        self.upCrv = upCrv
        self.downCrv = downCrv
    }
}

extension OperatorEnvelope: LivenDecodable {
    typealias LivenDecodeType = (LivenProto.AmpEnvelope, UInt8, LivenProto.Curve)

    public func updateFrom(liven: LivenDecodeType) {
        let (e, ts, c) = liven
        envelope.updateFrom(liven: e)
        timescale = Int(ts)
        upCrv = Int(c.up)
        downCrv = Int(c.down)
    }
}

extension OperatorEnvelope: LivenEncodable {
    typealias LivenEncodeType = (LivenProto.AmpEnvelope, UInt8, LivenProto.Curve)

    public func convertToLiven() -> LivenEncodeType {
        let e = envelope.convertToLiven()
        let ts = UInt8(timescale)
        let c = LivenProto.Curve.init(up: Int8(upCrv), down: Int8(downCrv))
        return (e, ts, c)
    }
}
