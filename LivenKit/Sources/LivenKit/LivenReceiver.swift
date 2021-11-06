import Foundation
import Combine
import zlib

enum LivenPacketType: UInt8 {
    case Header = 0x1
    case Body = 0x2
    case Footer = 0x3
}

public class LivenReceiver {
    enum State {
        case Waiting
        case ReadingBody
    }

    public enum ReceiverError: Error {
        case UnmatchedFooter
        case UnmatchedBody
        case ChecksumMismatch(expected: UInt32, actual: UInt32)
    }

    public var receivedPatch = CurrentValueSubject<LivenProto.FMTC?, Never>(nil)

    public init() {
        
    }

    // MARK: Reading Bytes

    private var buffer = Data()
    private var state: State = .Waiting
    private var inMessage = false

    public func onBytes<T: Collection>(_ bytes: T) where T.Element == UInt8, T.Index == Int {
        // print("onBytes(\(self.hex(bytes))")

        var base: T.SubSequence = bytes.suffix(from:0)
        while base.count != 0 {
            if (!inMessage) {
                // Must be an 0xF0 to trigger anything
                guard bytes.first == 0xF0 else { return }
                inMessage = true
                buffer = Data()
            }

            if let endOfMessage = bytes.firstIndex(of: 0xF7) {
                buffer.append(contentsOf: bytes.prefix(through: endOfMessage))

                self.onUnpackedPacket(buffer)

                buffer = Data()
                inMessage = false
                base = base.suffix(from: endOfMessage + 1)
            } else {
                buffer.append(contentsOf: bytes)
                return
            }
        }
    }

    private func onUnpackedPacket<T: Collection>(_ bytes: T) where T.Element == UInt8 {
        // print("onUnpackedPacket(\(self.hex(bytes))")

        var base = bytes.dropFirst().prefix { $0 != 0xf7 }

        var buf = Data.init()

        while true {
            let chunk = base.prefix(8)
            guard var highBits = chunk.first else { break }

            highBits <<= 1

            let packed = chunk.dropFirst().map { (x: UInt8) -> UInt8 in
                let result: UInt8 = x | (highBits & 0x80)
                highBits <<= 1
                return result
            }

            buf.append(contentsOf: packed)

            base = base.dropFirst(8)
        }

        self.onPacket(buf)
    }

    // MARK: Reading Packets

    private var header: LivenProto.HeaderPacket?
    private var body = Data()

    private func onPacket(_ packet: Data) {
        do {
            // print("onPacket(\(self.hex(packet))")

            let reader = LivenReader(withData: packet)

            // Constant header
            try reader.skip(bytes: 6)

            switch try reader.readType() {
            case .Header:
                self.header = try LivenProto.HeaderPacket.init(fromReader: reader)
                self.body = Data()
            case .Body:
                guard self.header != nil else {
                    throw ReceiverError.UnmatchedBody
                }
                self.body.append(reader.rest())
            case .Footer:
                guard let header = self.header else {
                    throw ReceiverError.UnmatchedFooter
                }
                let footer = try LivenProto.FooterPacket(fromReader: reader)

                let checksum = self.checksumPatch(body)
                guard footer.checksum == checksum else {
                    throw ReceiverError.ChecksumMismatch(expected: footer.checksum, actual: checksum)
                }

                self.onTransfer(header: header, body: self.body, footer: footer)
            }
        } catch {
            print("Error handling packet: \(error)")

        }
    }

    private func onTransfer(header: LivenProto.HeaderPacket, body: Data, footer: LivenProto.FooterPacket) {
        do {
            let reader = LivenReader(withData: body)
            let fmtc = try LivenProto.FMTC(withReader: reader)
            receivedPatch.send(fmtc)
        } catch {
            print("Received transfer but could not decode patch: \(error)")
        }
    }

    private func checksumPatch(_ buf: Data) -> UInt32 {
        return buf.withUnsafeBytes { (p: UnsafePointer<Bytef>) -> UInt32 in
            // This may seem like a magic constant, but it's more likely a constant prefix
            // that I have yet determine.
            return UInt32(crc32(~0x6046f7ed, p, UInt32(buf.count)))
        }
    }
}
