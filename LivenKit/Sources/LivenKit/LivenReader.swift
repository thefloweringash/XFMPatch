import Foundation

public class LivenReader {
    enum ReaderError: Error {
        case Underflow
        case UnknownPacket
        case InvalidFourCC
        case FourCCMismatch(expected: String, actual: String)
        case InvalidString
        case IntegerOverflow
        case NotEmpty(remaining: Int)
    }

    private var buffer: Data
    init(withData data: Data) {
        self.buffer = data
    }

    public func readInt<T: FixedWidthInteger>(_ type: T.Type) throws -> T {
        return T(truncatingIfNeeded: try readUInt(type.Magnitude, size: MemoryLayout<T>.size))
    }

    public func readInt<T: FixedWidthInteger>(_ type: T.Type, size: Int) throws -> T {
        return T(truncatingIfNeeded: try readUInt(type.Magnitude, size: size))
    }

    public func readType() throws -> LivenPacketType {
        guard let result = LivenPacketType.init(rawValue: try self.readInt(UInt8.self)) else {
            throw ReaderError.UnknownPacket
        }
        return result
    }

    public func skip(bytes: Int) throws {
        guard buffer.count >= bytes else {
            throw ReaderError.Underflow
        }
        buffer = buffer.advanced(by: bytes)
    }

    public func read(bytes: Int) throws -> Data {
        guard buffer.count >= bytes else {
            throw ReaderError.Underflow
        }
        let result = buffer.prefix(bytes)
        buffer = buffer.advanced(by: bytes)
        return result
    }

    public func rest() -> Data{
        let result = buffer
        buffer = buffer.advanced(by: buffer.count)
        return result
    }

    public func containerReader(fourCC expectedFourCCStr: String) throws -> LivenReader {
        let expectedFourCC = try LivenProto.fourCCToNumber(expectedFourCCStr)
        let actualFourCC = try readInt(UInt32.self)

        guard actualFourCC == expectedFourCC else {
            throw ReaderError.FourCCMismatch(
                expected: LivenProto.fourCCToString(expectedFourCC),
                actual: LivenProto.fourCCToString(actualFourCC)
            )
        }

        let length = Int(try readInt(UInt32.self) - 8)

        guard buffer.count >= length else {
            throw ReaderError.Underflow
        }

        let subRange = buffer.prefix(length)
        buffer = buffer.advanced(by: length)

        return LivenReader(withData: subRange)
    }

    public func readPascalString<T: FixedWidthInteger>(_ type: T.Type) throws -> String {
        let length = Int(try readInt(type))
        let body = try read(bytes: length)
        guard let result = String(data: body, encoding: .ascii) else {
            throw ReaderError.InvalidString
        }
        return result
    }

    public func assertDrained() throws {
        if !buffer.isEmpty {
            throw ReaderError.NotEmpty(remaining: buffer.count)
        }
    }

    // Convert a number of bytes
    private func readUInt<T: UnsignedInteger>(_: T.Type, size: Int) throws -> T {
        guard size <= MemoryLayout<T>.size else {
            throw ReaderError.IntegerOverflow
        }
        guard buffer.count >= size else {
            throw ReaderError.Underflow
        }

        let shift = (size - 1) << 3

        var result: T = 0
        for b in buffer.prefix(size) {
            result = result >> 8 | T(b) << shift
        }
        buffer = buffer.advanced(by: size)
        return result
    }
}
