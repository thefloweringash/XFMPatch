import Foundation
import LivenKit

final class PitchEG: ObservableObject {
    public let envelope: PitchEnvelope

    @Published public var o1e: Bool
    @Published public var o2e: Bool
    @Published public var o3e: Bool
    @Published public var o4e: Bool

    public convenience init() {
        self.init(
            envelope: PitchEnvelope(l1: 0, t1: 0, l2: 0, t2: 0, l3: 0, t3: 0, l4: 0, t4: 0),
            o1e: false,
            o2e: false,
            o3e: false,
            o4e: false
        )
    }

    public init(
        envelope: PitchEnvelope,
        o1e: Bool,
        o2e: Bool,
        o3e: Bool,
        o4e: Bool
    ) {
        self.envelope = envelope
        self.o1e = o1e
        self.o2e = o2e
        self.o3e = o3e
        self.o4e = o4e
    }
}

extension PitchEG: LivenDecodable {
    typealias LivenDecodeType = (LivenProto.PitchEnvelope, LivenProto.PerOp<UInt8>)

    public func updateFrom(liven: LivenDecodeType) {
        let (env, peg) = liven
        envelope.updateFrom(liven: env)
        (o1e, o2e, o3e, o4e) = LivenProto.mapPerOp(peg) { $0 == 1 }
    }
}

extension PitchEG: LivenEncodable {
    typealias LivenEncodeType = (LivenProto.PitchEnvelope, LivenProto.PerOp<UInt8>)

    public func convertToLiven() -> LivenEncodeType {
        let env = envelope.convertToLiven()
        let peg: LivenProto.PerOp<UInt8> = LivenProto.mapPerOp((o1e, o2e, o3e, o4e)) { $0 ? 1 : 0 }
        return (env, peg)
    }
}
