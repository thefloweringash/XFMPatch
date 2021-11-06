import Foundation
import LivenKit

final class Envelope: ObservableObject {
    @Published public var L1: Int = 127;
    @Published public var L2: Int = 127;
    @Published public var L3: Int = 127;
    @Published public var L4: Int = 0;

    @Published public var T1: Int = 0;
    @Published public var T2: Int = 0;
    @Published public var T3: Int = 0;
    @Published public var T4: Int = 0;

    @Published public var timescale: Int = 0
    @Published public var upCrv: Int = 0
    @Published public var downCrv: Int = 0

    public init() {
    }

    public init(
        l1: Int, t1: Int,
        l2: Int, t2: Int,
        l3: Int, t3: Int,
        l4: Int, t4: Int,
        timescale: Int,
        upCrv: Int,
        downCrv: Int
    ) {
        self.L1 = l1
        self.L2 = l2
        self.L3 = l3
        self.L4 = l4

        self.T1 = t1
        self.T2 = t2
        self.T3 = t3
        self.T4 = t4
    }
}

extension Envelope: LivenDecodable {
    typealias LivenDecodeType = (LivenProto.Envelope, UInt8, LivenProto.Curve)

    public func updateFrom(liven: LivenDecodeType) {
        let (e, ts, c) = liven
        L1 = Int(e.aLevel)
        L2 = Int(e.dLevel)
        L3 = Int(e.sLevel)
        L4 = Int(e.rLevel)
        T1 = Int(e.aTime)
        T2 = Int(e.dTime)
        T3 = Int(e.sTime)
        T4 = Int(e.rTime)
        timescale = Int(ts)
        upCrv = Int(c.up)
        downCrv = Int(c.down)
    }
}

extension Envelope: LivenEncodable {
    typealias LivenEncodeType = (LivenProto.Envelope, UInt8, LivenProto.Curve)

    public func convertToLiven() -> LivenEncodeType {
        let e = LivenProto.Envelope.init(
            aTime: UInt8(T1),
            dTime: UInt8(T2),
            sTime: UInt8(T3),
            rTime: UInt8(T4),
            aLevel: UInt8(L1),
            dLevel: UInt8(L2),
            sLevel: UInt8(L3),
            rLevel: UInt8(L4)
        )
        let ts = UInt8(timescale)
        let c = LivenProto.Curve.init(up: Int8(upCrv), down: Int8(downCrv))
        return (e, ts, c)
    }
}
