import Foundation

final class Operator: ObservableObject {
    public enum Index {
        case Op1
        case Op2
        case Op3
        case Op4
    }

    @Published public var ratio: Float
    @Published public var level: UInt8
    @Published public var fixed: Bool
    @Published public var frequency: Float

    public let envelope: Envelope
    public let scale: Scale

    public convenience init() {
        self.init(
            ratio: 1.0,
            level: 63,
            fixed: false,
            frequency: 440,
            envelope: Envelope(),
            scale: Scale()
        )
    }

    public init(
        ratio: Float,
        level: UInt8,
        fixed: Bool,
        frequency: Float,
        envelope: Envelope,
        scale: Scale
    ) {
        self.ratio = ratio
        self.level = level
        self.fixed = fixed
        self.frequency = frequency
        self.envelope = envelope
        self.scale = scale
    }
}

extension Operator: LivenReceiverDecodable {
    typealias LivenReceiverType = (
        LivenProto.TPDT.Fixed,
        LivenProto.TPDT.Ratio,
        LivenProto.TPDT.Envelope,
        LivenProto.TPDT.Scale
    )

    func updateFrom(liven: LivenReceiverType) {
        let (f, r, e, s) = liven
        ratio = r.ratio
        level = r.level
        fixed = f.fixed
        frequency = f.frequency
        envelope.updateFrom(liven: e)
        scale.updateFrom(liven: s)
    }

    public class func gatherParams(tpdt: LivenProto.TPDT, index: Index) -> LivenReceiverType {
        switch index {
        case .Op1: return (tpdt.fixed.0, tpdt.ratio.0, tpdt.envelope.0, tpdt.scale.0)
        case .Op2: return (tpdt.fixed.1, tpdt.ratio.1, tpdt.envelope.1, tpdt.scale.1)
        case .Op3: return (tpdt.fixed.2, tpdt.ratio.2, tpdt.envelope.2, tpdt.scale.2)
        case .Op4: return (tpdt.fixed.3, tpdt.ratio.3, tpdt.envelope.3, tpdt.scale.3)
        }
    }
}
