import Foundation
import LivenKit

final class Bank: ObservableObject {
    @Published public var name: String = "BK01"
    @Published public var patches: [Patch]

    public convenience init() {
        let emptyPatches = (1...16).map { i in
            Patch(name: String(format: "TP.%.2d", i))
        }
        self.init(
            name: "BK01",
            patches: emptyPatches
        )
    }

    public init(name: String, patches: [Patch]) {
        self.name = name
        self.patches = patches
    }
}

extension Bank: LivenDecodable {
    func updateFrom(liven bank: LivenProto.FMBC) {
        name = bank.fmnm.name
        for (i, p) in bank.bkdt.patches.enumerated() {
            patches[i].updateFrom(liven: p)
        }
    }

    typealias LivenDecodeType = LivenProto.FMBC
}
