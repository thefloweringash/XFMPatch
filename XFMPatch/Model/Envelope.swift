import Foundation
import LivenKit

final class Envelope<T>: ObservableObject where T: FixedWidthInteger {
    @Published public var L1: Int
    @Published public var L2: Int
    @Published public var L3: Int
    @Published public var L4: Int

    @Published public var T1: Int
    @Published public var T2: Int
    @Published public var T3: Int
    @Published public var T4: Int

    public convenience init() {
        self.init(
            l1: 0, t1: 0,
            l2: 0, t2: 0,
            l3: 0, t3: 0,
            l4: 0, t4: 0
        )
    }

    public init(
        l1: Int, t1: Int,
        l2: Int, t2: Int,
        l3: Int, t3: Int,
        l4: Int, t4: Int
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

    var levels: LivenProto.PerOp<Int> {
        (L1, L2, L3, L4)
    }

    var times: LivenProto.PerOp<Int> {
        (T1, T2, T3, T4)
    }
}

extension Envelope: LivenDecodable {
    typealias LivenDecodeType = LivenProto.Envelope<T>

    public func updateFrom(liven: LivenDecodeType) {
        let e = liven
        (L1, L2, L3, L4) = LivenProto.mapPerOp(e.levels) { Int($0) }
        (T1, T2, T3, T4) = LivenProto.mapPerOp(e.times) { Int($0) }
    }
}

extension Envelope: LivenEncodable {
    typealias LivenEncodeType = LivenProto.Envelope<T>

    public func convertToLiven() -> LivenEncodeType {
        return .init(
            times: LivenProto.mapPerOp(times) { UInt8($0) },
            levels: LivenProto.mapPerOp(levels) { T($0) }
        )
    }
}

typealias AmpEnvelope = Envelope<UInt8>
typealias PitchEnvelope = Envelope<Int8>
