import Foundation

public class LivenWriter {
    enum WriterError: Error, Equatable {
        case IntegerOverflow
        case ContainerOverflow(expected: Int, actual: Int)
        case ContainerUnderflow(expected: Int, actual: Int)

    }

    private var buffer = Data()

    public func writeUInt<T: UnsignedInteger>(_ val: T) throws -> Void {
        try writeUInt(val, size: MemoryLayout<T>.size)
    }

    // Convert a number of bytes
    public func writeUInt<T: UnsignedInteger>(_ val: T, size: Int) throws {
        guard size <= MemoryLayout<T>.size else {
            throw WriterError.IntegerOverflow
        }

        var x = val

        for _ in 0..<size {
            buffer.append(UInt8(x & 0xff))
            x >>= 8
        }
    }

    public func writeInt<T: SignedInteger>(_ val: T) throws -> Void where T.Magnitude : UnsignedInteger {
        try writeUInt(T.Magnitude(truncatingIfNeeded: val))
    }

    public func writeContainer(fourCC: String, body: (LivenWriter) throws -> Void) throws {
        try writeContainer(fourCC: fourCC, size: nil, pad: nil, body: body)
    }

    public func writeContainer(fourCC: String, size: Int?, pad: UInt8?, body: (LivenWriter) throws -> Void) throws {
        let subwriter = LivenWriter()
        try body(subwriter)
        var containerData = subwriter.get()

        var totalSize = containerData.count + 8

        if let size = size {
            if totalSize > size {
                throw WriterError.ContainerOverflow(expected: size, actual: totalSize)
            }

            if pad == nil && totalSize != size {
                throw WriterError.ContainerUnderflow(expected: size, actual: totalSize)
            }

            if let pad = pad {
                for _ in 0..<(size-totalSize) {
                    containerData.append(pad)
                }
                totalSize = size
            }
        }

        try writeUInt(LivenProto.fourCCToNumber(fourCC))
        try writeUInt(UInt32(totalSize))
        buffer.append(containerData)
    }

    public func get() -> Data {
        let result = buffer
        buffer = Data()
        return result
    }
}
