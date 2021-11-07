import Foundation
import LivenKit

final class Patch: ObservableObject {
    @Published public var name: String

    public let operators: (Operator, Operator, Operator, Operator)
    public let matrix: Matrix
    public let pitchEnvelope: PitchEnvelope

    public convenience init() {
        self.init(
            name: "INIT",
            operators: (Operator(), Operator(), Operator(), Operator()),
            matrix: Matrix(),
            pitchEnvelope: PitchEnvelope()
        )
    }

    public init(
        name: String,
        operators: (Operator, Operator, Operator, Operator),
        matrix: Matrix,
        pitchEnvelope: PitchEnvelope
    ) {
        self.name = name
        self.operators = operators
        self.matrix = matrix
        self.pitchEnvelope = pitchEnvelope
    }
}

extension Patch: LivenDecodable {
    typealias LivenDecodeType = LivenProto.FMTC
    
    public func updateFrom(liven fmtc: LivenProto.FMTC) {
        let tpdt = fmtc.tpdt

        name = fmtc.fmnm.name

        operators.0.updateFrom(liven: Operator.gatherParams(tpdt: tpdt, index: .Op1))
        operators.1.updateFrom(liven: Operator.gatherParams(tpdt: tpdt, index: .Op2))
        operators.2.updateFrom(liven: Operator.gatherParams(tpdt: tpdt, index: .Op3))
        operators.3.updateFrom(liven: Operator.gatherParams(tpdt: tpdt, index: .Op4))

        matrix.updateFrom(liven: tpdt.matrix)
    }
}

extension Patch: LivenEncodable {
    typealias LivenEncodeType = LivenProto.FMTC

    public func convertToLiven() -> LivenProto.FMTC {
        let (o1f, o1r, o1e, o1s, o1v, o1ts, o1p, o1c) = operators.0.convertToLiven()
        let (o2f, o2r, o2e, o2s, o2v, o2ts, o2p, o2c) = operators.1.convertToLiven()
        let (o3f, o3r, o3e, o3s, o3v, o3ts, o3p, o3c) = operators.2.convertToLiven()
        let (o4f, o4r, o4e, o4s, o4v, o4ts, o4p, o4c) = operators.3.convertToLiven()

        let fmnm = LivenProto.FMNM.init(name: name)
        let tpdt = LivenProto.TPDT.init(
            fixed: (o1f, o2f, o3f, o4f),
            ratio: (o1r, o2r, o3r, o4r),
            envelope: (o1e, o2e, o3e, o4e),
            pitchEnvelope: pitchEnvelope.convertToLiven(),
            scale: (o1s, o2s, o3s, o4s),
            matrix: matrix.convertToLiven(),
            velocity: (o1v, o2v, o3v, o4v),
            timescale: (o1ts, o2ts, o3ts, o4ts),
            pitchEG: (o1p, o2p, o3p, o4p),
            curve: (o1c, o2c, o3c, o4c)
        )
        return LivenProto.FMTC.init(fmnm: fmnm, tpdt: tpdt)
    }
}