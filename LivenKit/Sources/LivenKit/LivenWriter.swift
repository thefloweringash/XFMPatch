import Foundation

public class LivenWriter {
    enum WriterError: Error, Equatable {
        case IntegerOverflow
        case ContainerOverflow(expected: Int, actual: Int)
        case ContainerUnderflow(expected: Int, actual: Int)
        case NonAsciiString
    }

    private var buffer = Data()

    public func writeInt<T: FixedWidthInteger>(_ val: T) throws -> Void {
        try writeUInt(T.Magnitude(truncatingIfNeeded: val), size: MemoryLayout<T>.size)
    }

    public func writeInt<T: FixedWidthInteger>(_ val: T, size: Int) throws -> Void {
        try writeUInt(T.Magnitude(truncatingIfNeeded: val), size: size)
    }

    public func writeContainer(fourCC: String, body: (LivenWriter) throws -> Void) throws {
        try writeContainer(fourCC: fourCC, size: nil, pad: nil, body: body)
    }

    public func writeContainer(fourCC: String, size: Int?, pad: UInt8?, body: (LivenWriter) throws -> Void) throws {
        let subwriter = LivenWriter()
        try body(subwriter)
        var containerData = subwriter.get()

        var totalSize = containerData.count + 8

        if let size {
            if totalSize > size {
                throw WriterError.ContainerOverflow(expected: size, actual: totalSize)
            }

            if pad == nil && totalSize != size {
                throw WriterError.ContainerUnderflow(expected: size, actual: totalSize)
            }

            if let pad {
                for _ in 0..<(size - totalSize) {
                    containerData.append(pad)
                }
                totalSize = size
            }
        }

        try writeInt(LivenProto.fourCCToNumber(fourCC))
        try writeInt(UInt32(totalSize))
        buffer.append(containerData)
    }

    public func writePascalString<T: FixedWidthInteger>(_ type: T.Type, _ string: String) throws -> Void {
        guard let stringAsAscii = string.data(using: .ascii) else {
            throw WriterError.NonAsciiString
        }
        try writeInt(T(stringAsAscii.count))
        buffer.append(stringAsAscii)
    }

    public func writeData(_ data: Data) {
        buffer.append(data)
    }

    public func writeBytes(_ bytes: some Collection<UInt8>) {
        buffer.append(contentsOf: bytes)
    }

    public func get() -> Data {
        let result = buffer
        buffer = Data()
        return result
    }

    // Convert a number of bytes
    private func writeUInt<T: UnsignedInteger>(_ val: T, size: Int) throws {
        guard size <= MemoryLayout<T>.size else {
            throw WriterError.IntegerOverflow
        }

        var x = val

        for _ in 0..<size {
            buffer.append(UInt8(x & 0xFF))
            x >>= 8
        }
    }
}
