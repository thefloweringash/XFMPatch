import Foundation

public class LivenSender {
    enum Errors: Error {
        case UnknownSysexHeaderParam
        case UnknownChecksumXorIn
    }

    public func toSysEx(struct: AnyLivenStruct) throws -> Data {
        try toSysEx(`struct`.toWritable(), type: `struct`.structType())
    }

    public func toSysEx(_ x: LivenWritable, type: LivenStructType) throws -> Data {
        guard let headerUnknown = type.headerUnknown else {
            throw Errors.UnknownSysexHeaderParam
        }

        guard let checksumInit = type.initVal else {
            throw Errors.UnknownChecksumXorIn
        }

        let data = try x.toData()

        let header = LivenProto.HeaderPacket(unknown: headerUnknown, length: UInt32(data.count))
        let footer = LivenProto.FooterPacket(checksum: checksum(initVal: checksumInit, buf: data))
        return try pack(.Header(header), .Body(data), .Footer(footer))
    }

    public func pack(_ packets: AnyLivenPacket...) throws -> Data {
        var buf = Data()

        for p in packets {
            try buf.append(wrapInSysEx(p.toData()))
        }

        return buf
    }

    func splitHighBits(_ data: some Collection<UInt8>) -> Data {
        var buf = Data()
        var p = data.dropFirst(0)
        while !p.isEmpty {
            let chunk = p.prefix(7)

            var highBits: UInt8 = 0

            let split = chunk.enumerated().map { i, b -> UInt8 in
                highBits |= (b & 0x80) == 0 ? 0 : 1 << (6 - i)
                return b & 0x7F
            }

            buf.append(highBits)
            buf.append(contentsOf: split)

            p = p.dropFirst(7)
        }
        return buf
    }

    private func wrapInSysEx(_ data: Data) -> Data {
        var buf = Data()

        buf.append(0xF0)
        buf.append(splitHighBits(data))
        buf.append(0xF7)

        return buf
    }
}
