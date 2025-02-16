import Foundation
import LivenKit

final class Patch: ObservableObject, Identifiable {
    @Published public var name: String

    public let operators: (Operator, Operator, Operator, Operator)
    public let matrix: Matrix
    public let pitchEnvelope: PitchEG

    public convenience init() {
        self.init(
            name: "INIT",
            operators: (Operator(), Operator(), Operator(), Operator()),
            matrix: Matrix(),
            pitchEnvelope: PitchEG()
        )
    }

    public convenience init(name: String) {
        self.init(
            name: name,
            operators: (Operator(), Operator(), Operator(), Operator()),
            matrix: Matrix(),
            pitchEnvelope: PitchEG()
        )
    }

    public init(
        name: String,
        operators: (Operator, Operator, Operator, Operator),
        matrix: Matrix,
        pitchEnvelope: PitchEG
    ) {
        self.name = name
        self.operators = operators
        self.matrix = matrix
        self.pitchEnvelope = pitchEnvelope
    }

    typealias ID = String

    var id: String { name }
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
        pitchEnvelope.updateFrom(liven: (tpdt.pitchEnvelope, tpdt.pitchEG))
    }
}

extension Patch: LivenEncodable {
    typealias LivenEncodeType = LivenProto.FMTC

    public func convertToLiven() -> LivenProto.FMTC {
        let (o1f, o1r, o1e, o1s, o1v, o1ts, o1c) = operators.0.convertToLiven()
        let (o2f, o2r, o2e, o2s, o2v, o2ts, o2c) = operators.1.convertToLiven()
        let (o3f, o3r, o3e, o3s, o3v, o3ts, o3c) = operators.2.convertToLiven()
        let (o4f, o4r, o4e, o4s, o4v, o4ts, o4c) = operators.3.convertToLiven()

        let (peg, pegEnable) = pitchEnvelope.convertToLiven()

        let fmnm = LivenProto.FMNM(name: name)
        let tpdt = LivenProto.TPDT(
            fixed: (o1f, o2f, o3f, o4f),
            ratio: (o1r, o2r, o3r, o4r),
            envelope: (o1e, o2e, o3e, o4e),
            pitchEnvelope: peg,
            scale: (o1s, o2s, o3s, o4s),
            matrix: matrix.convertToLiven(),
            velocity: (o1v, o2v, o3v, o4v),
            timescale: (o1ts, o2ts, o3ts, o4ts),
            pitchEG: pegEnable,
            curve: (o1c, o2c, o3c, o4c)
        )
        return LivenProto.FMTC(fmnm: fmnm, tpdt: tpdt)
    }
}
