import Combine
@testable import LivenKit
import XCTest

class LivenSenderTests: XCTestCase {
    private let sender = LivenSender()
    private let receiver = LivenReceiver()
    private var lastTransfer: AnyLivenStruct?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        receiver.inboundTransfers.sink { [weak self] s in
            guard let self else { return }
            lastTransfer = s
        }.store(in: &cancellables)
    }

    public func testBitSplittingSmall() {
        let testData = Data([0xFF, 0xFF])

        let split = sender.splitHighBits(testData)
        XCTAssertEqual(Data([1 << 6 | 1 << 5, 0x7F, 0x7F]), split)
    }

    public func testsBitCombiningSmall() {
        let testData = Data([1 << 6 | 1 << 5, 0x7F, 0x7F])

        let split = receiver.combineHighBits(testData)
        XCTAssertEqual(Data([0xFF, 0xFF]), split)
    }

    public func testBitPackingRandom() {
        let testData = Data(base64Encoded: """
            /q9Qtpdxa/i/OkzHUFuXzVfc5XIFA3cPG2dqE0QGe9xWxKGE7XS0luk4FGiDwCJ9nat+C9hXLQ+w
            bbojHDOVPK8dyAFhU/6D5uG90GnVXl8vO174q0I3TSggAOeDRKfvoRrXAwUG0sWuOcMzxlg1RD9l
            wIa19ewVqll6gBsuxLs=
        """, options: .ignoreUnknownCharacters)!

        let roundTripped = receiver.combineHighBits(sender.splitHighBits(testData))
        XCTAssertEqual(testData, roundTripped)
    }

    public func testRoundtripPatch() throws {
        // Init patch, but named WGGL (you'll never guess how this was derived)
        let initPatch = Data(base64Encoded: """
            8ABIBAAAA2ABBAAAAAA8AAAAAPfwAEgEAAADYAIERk1UQzwAAAAAAAAAAAIAAAAARk1OTRQAAAAA
            AAAAAAAEAAAAV0dHAkxUUERUGAAAAAAAAAAAAQAAAAAAAAAAAAAwEQAAMBEAAAAwEQAAMAARAGQA
            PwBkAAA/AGQAPwAAZAA/AAAAAAAAf39/AAAAAAAAf39/AAAAAAAAf39/AAAAAAAAf39/AAAAAAAA
            AAAAAAAAAAADAAAAAAMAAAADAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAB/AAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAPfwAEgEAAADYAMgaxYiD/c=
        """, options: .ignoreUnknownCharacters)!

        receiver.onBytes(initPatch)

        let result = try sender.toSysEx(struct: lastTransfer!)
        XCTAssertEqual(initPatch, result)
    }
}
