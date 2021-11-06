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

        var id: UInt8 {
            get { self.rawValue }
        }

        var description: String {
            switch self {
            case .Ratio: return "Ratio"
            case .Fixed: return "Fixed"
            }
        }
    }

    @Published public var ratio: Float
    @Published public var level: Float
    @Published public var mode: OperatorMode
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
        self.level = Float(level)
        self.mode = fixed ? .Fixed : .Ratio
        self.frequency = frequency
        self.envelope = envelope
        self.scale = scale
    }
}

extension Operator: LivenDecodable {
    typealias LivenDecodeType = (
        LivenProto.Fixed,
        LivenProto.Ratio,
        LivenProto.Envelope,
        LivenProto.Scale
    )

    func updateFrom(liven: LivenDecodeType) {
        let (f, r, e, s) = liven
        ratio = r.ratio
        level = Float(r.level)
        mode = f.fixed ? .Fixed : .Ratio
        frequency = f.frequency
        envelope.updateFrom(liven: e)
        scale.updateFrom(liven: s)
    }

    public class func gatherParams(tpdt: LivenProto.TPDT, index: Index) -> LivenDecodeType {
        switch index {
        case .Op1: return (tpdt.fixed.0, tpdt.ratio.0, tpdt.envelope.0, tpdt.scale.0)
        case .Op2: return (tpdt.fixed.1, tpdt.ratio.1, tpdt.envelope.1, tpdt.scale.1)
        case .Op3: return (tpdt.fixed.2, tpdt.ratio.2, tpdt.envelope.2, tpdt.scale.2)
        case .Op4: return (tpdt.fixed.3, tpdt.ratio.3, tpdt.envelope.3, tpdt.scale.3)
        }
    }
}
