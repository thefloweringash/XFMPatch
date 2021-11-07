import Foundation

class PatchStorage: ObservableObject {
    enum PatchData: Identifiable {
        typealias ID = Int

        case Bank(_: Bank, serial: Int)
        case Patch(_: Patch, serial: Int)

        var id: Int {
            switch self {
            case .Bank(_, let serial): return serial
            case .Patch(_, let serial): return serial
            }
        }
    }

    @Published public var data: [PatchData] = []

    private var serial = 1

    init() {
        data = [ .Patch(Patch(), serial: 0) ]
    }

    func append(bank: Bank) {
        data.append(.Bank(bank, serial: nextSerial()))
    }

    func append(patch: Patch) {
        data.append(.Patch(patch, serial: nextSerial()))
    }

    private func nextSerial() -> Int {
        defer { serial += 1 }
        return serial
    }
}
