import Foundation

final class Patch: ObservableObject {
    @Published public var name: String

    public let operators: (Operator, Operator, Operator, Operator)

    public convenience init() {
        self.init(
            name: "INIT",
            operators: (Operator(), Operator(), Operator(), Operator())
        )
    }

    public init(
        name: String,
        operators: (Operator, Operator, Operator, Operator)
    ) {
        self.name = name
        self.operators = operators
    }
}

extension Patch: LivenReceiverDecodable {
    typealias LivenReceiverType = LivenProto.FMTC
    
    public func updateFrom(liven fmtc: LivenProto.FMTC) {
        let tpdt = fmtc.tpdt

        name = fmtc.fmnm.name

        operators.0.updateFrom(liven: Operator.gatherParams(tpdt: tpdt, index: .Op1))
        operators.1.updateFrom(liven: Operator.gatherParams(tpdt: tpdt, index: .Op2))
        operators.2.updateFrom(liven: Operator.gatherParams(tpdt: tpdt, index: .Op3))
        operators.3.updateFrom(liven: Operator.gatherParams(tpdt: tpdt, index: .Op4))
    }
}
