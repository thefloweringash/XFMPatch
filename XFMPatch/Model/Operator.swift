import Foundation
import LivenKit

final class Operator: ObservableObject {
    public enum Index {
        case Op1
        case Op2
        case Op3
        case Op4
    }

    public enum OperatorMode: UInt8, Identifiable, CaseIterable, CustomStringConvertible {
        case Ratio = 1
        case Fixed = 2

        var id: UInt8 { rawValue }

        var description: String {
            switch self {
            case .Ratio: return "Ratio"
            case .Fixed: return "Fixed"
            }
        }
    }

    @Published public var ratio: Float
    @Published public var level: UInt8

    @Published public var mode: OperatorMode
    @Published public var frequency: Float
    @Published public var detune: Int8
    @Published public var velocity: UInt8

    public let envelope: OperatorEnvelope
    public let scale: Scale

    public convenience init() {
        self.init(
            ratio: 1.0,
            level: 63,
            fixed: false,
            frequency: 440,
            detune: 0,
            velocity: 0,
            envelope: OperatorEnvelope(),
            scale: Scale()
        )
    }

    public init(
        ratio: Float,
        level: UInt8,
        fixed: Bool,
        frequency: Float,
        detune: Int8,
        velocity: UInt8,
        envelope: OperatorEnvelope,
        scale: Scale
    ) {
        self.ratio = ratio
        self.level = level
        mode = fixed ? .Fixed : .Ratio
        self.frequency = frequency
        self.detune = detune
        self.velocity = velocity
        self.envelope = envelope
        self.scale = scale
    }
}

extension Operator: LivenDecodable {
    typealias LivenDecodeType = (
        LivenProto.Fixed,
        LivenProto.Ratio,
        LivenProto.AmpEnvelope,
        LivenProto.Scale,
        UInt8,
        UInt8,
        LivenProto.Curve
    )

    func updateFrom(liven: LivenDecodeType) {
        let (f, r, e, s, v, ts, c) = liven
        ratio = r.ratio
        level = r.level
        mode = f.fixed ? .Fixed : .Ratio
        frequency = f.frequency
        detune = r.detune
        velocity = v
        envelope.updateFrom(liven: (e, ts, c))
        scale.updateFrom(liven: s)
    }

    public class func gatherParams(tpdt: LivenProto.TPDT, index: Index) -> LivenDecodeType {
        switch index {
        case .Op1: return (
                tpdt.fixed.0, tpdt.ratio.0, tpdt.envelope.0, tpdt.scale.0,
                tpdt.velocity.0, tpdt.timescale.0, tpdt.curve.0
            )
        case .Op2: return (
                tpdt.fixed.1, tpdt.ratio.1, tpdt.envelope.1, tpdt.scale.1,
                tpdt.velocity.1, tpdt.timescale.1, tpdt.curve.1
            )
        case .Op3: return (
                tpdt.fixed.2, tpdt.ratio.2, tpdt.envelope.2, tpdt.scale.2,
                tpdt.velocity.2, tpdt.timescale.2, tpdt.curve.2
            )
        case .Op4: return (
                tpdt.fixed.3, tpdt.ratio.3, tpdt.envelope.3, tpdt.scale.3,
                tpdt.velocity.3, tpdt.timescale.3, tpdt.curve.3
            )
        }
    }
}

extension Operator: LivenEncodable {
    typealias LivenEncodeType = (
        LivenProto.Fixed,
        LivenProto.Ratio,
        LivenProto.AmpEnvelope,
        LivenProto.Scale,
        UInt8,
        UInt8,
        LivenProto.Curve
    )

    func convertToLiven() -> LivenEncodeType {
        let f = LivenProto.Fixed(fixed: mode == .Fixed, frequency: frequency)
        let r = LivenProto.Ratio(ratio: ratio, level: UInt8(level), detune: Int8(detune))
        let (e, ts, c) = envelope.convertToLiven()
        let s = scale.convertToLiven()
        let v = UInt8(velocity)

        return (f, r, e, s, v, ts, c)
    }
}
