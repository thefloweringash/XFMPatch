import XCTest
import Combine
@testable import LivenKit

class LivenSenderTests: XCTestCase {
    private let sender = LivenSender()
    private let receiver = LivenReceiver()
    private var lastTransfer: AnyLivenStruct?
    private var cancellables = Set<AnyCancellable>();

    override func setUp() {
        receiver.inboundTransfers.sink { [weak self] s in
            guard let self = self else { return }
            self.lastTransfer = s
        }.store(in: &cancellables)
    }

    public func testBitSplittingSmall() {
        let testData = Data([0xff, 0xff])

        let split = sender.splitHighBits(testData)
        XCTAssertEqual(Data([1 << 6 | 1 << 5, 0x7f, 0x7f]), split)
    }

    public func testsBitCombiningSmall() {
        let testData = Data([1 << 6 | 1 << 5, 0x7f, 0x7f])

        let split = receiver.combineHighBits(testData)
        XCTAssertEqual(Data([0xff, 0xff]), split)
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
