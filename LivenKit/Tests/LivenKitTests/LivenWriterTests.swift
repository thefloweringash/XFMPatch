@testable import LivenKit
import XCTest

class LivenWriterTests: XCTestCase {
    private var writer: LivenWriter = .init()

    override func setUp() {
        writer = LivenWriter()
    }

    public func toReader() -> LivenReader {
        LivenReader(withData: writer.get())
    }

    func roundTripUInt<T>(_ x: T) throws -> T where T: FixedWidthInteger {
        try writer.writeInt(x)
        return try toReader().readInt(T.self)
    }

    func roundTripUInt<T>(_ x: T, size: Int) throws -> T where T: FixedWidthInteger {
        try writer.writeInt(x, size: size)
        return try toReader().readInt(T.self, size: size)
    }

    func roundTripInt<T>(_ x: T) throws -> T where T: FixedWidthInteger {
        try writer.writeInt(x)
        return try toReader().readInt(T.self)
    }

    func testWriteUInt32() throws {
        let uint32: [UInt32] = [
            UInt32.min, UInt32.max,
            0x1234_5678, 0xFF00_0000, 0x0000_00FF,
        ]

        for c in uint32 {
            XCTAssertEqual(try roundTripUInt(c), c)
        }
    }

    func testWriteUInt8() throws {
        let uint8: [UInt8] = [UInt8.min, UInt8.max, 0x0F]

        for c in uint8 {
            XCTAssertEqual(try roundTripUInt(c), c)
        }
    }

    func testWriteUInt24() throws {
        let uint24: [UInt32] = [0x00FF_0000]

        for c in uint24 {
            XCTAssertEqual(try roundTripUInt(c, size: 3), c)
        }
    }

    func testWriteInt32() throws {
        let int32: [Int32] = [Int32.max, Int32.min]

        for c in int32 {
            XCTAssertEqual(try roundTripInt(c), c)
        }
    }

    func testRoundtripPascalString() throws {
        let testString = "Hello, world"
        try writer.writePascalString(UInt32.self, testString)
        let read = try toReader().readPascalString(UInt32.self)
        XCTAssertEqual(testString, read)
    }

    func testContainerWriterUnbounded() throws {
        let x: UInt32 = 0x1234_5678
        try writer.writeContainer(fourCC: "FMNM") { subw in
            try subw.writeInt(x)
        }
        let y = try toReader().containerReader(fourCC: "FMNM").readInt(UInt32.self)
        XCTAssertEqual(x, y)
    }

    func testContainerWriterPadding() throws {
        try writer.writeContainer(fourCC: "FMNM", size: 24, pad: 0xFF) { subw in
            try subw.writeInt(UInt8(0x60))
        }
        let y = try toReader().containerReader(fourCC: "FMNM").readInt(UInt32.self)
        XCTAssertEqual(0xFFFF_FF60, y)
    }

    func testContainerWriterChecking() throws {
        XCTAssertThrowsError(
            try writer.writeContainer(fourCC: "FMNM", size: 24, pad: nil) { subw in
                try subw.writeInt(UInt8(0x60))
            },
            "writeContainer must throw an error if the body does not fill the specified length"
        ) { error in
            XCTAssertEqual(error as! LivenWriter.WriterError,
                           LivenWriter.WriterError.ContainerUnderflow(expected: 24, actual: 9))
        }
    }
}
