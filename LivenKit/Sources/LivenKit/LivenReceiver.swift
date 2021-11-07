import Foundation
import Combine
import zlib

enum LivenPacketType: UInt8 {
    case Header = 0x1
    case Body = 0x2
    case Footer = 0x3
}

public enum AnyLivenStruct {
    case Name(_: LivenProto.FMNM)
    case BankContainer(_: LivenProto.FMBC)
    case TemplateContainer(_: LivenProto.FMTC)
    case BankData(_: LivenProto.BKDT)
    case TemplateData(_: LivenProto.TPDT)
}

public enum LivenStructType: String {
    case Name = "FMNM"
    case BankContainer = "FMBC"
    case TemplateContainer = "FMTC"
    case BankData = "BKDT"
    case TemplateData = "TPDT"

    var fourCC: UInt32 {
        try! LivenProto.fourCCToNumber(rawValue)
    }

    var crcXorIn: UInt32? {
        switch self {
        case .TemplateContainer: return 0x6046f7ed
        case .BankContainer: return 0xfb01478d
        default:
            return nil
        }
    }

    var initVal: UInt32? {
        guard let crcXorIn = self.crcXorIn else { return nil }
        return ~crcXorIn
    }

    static func fromFourCC(_ fourCC: UInt32) -> Self? {
        LivenStructType(rawValue: LivenProto.fourCCToString(fourCC))
    }

    func decode(withData buf: Data) throws -> AnyLivenStruct {
        let r = LivenReader(withData: buf)
        switch self {
        case .Name:
            return .Name(try LivenProto.FMNM(withReader: r))
        case .BankContainer:
            return .BankContainer(try LivenProto.FMBC(withReader: r))
        case .TemplateContainer:
            return .TemplateContainer(try LivenProto.FMTC(withReader: r))
        case .BankData:
            return .BankData(try LivenProto.BKDT(withReader: r))
        case .TemplateData:
            return .TemplateData(try LivenProto.TPDT(withReader: r))
        }
    }
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
        case UnknownContainer(type: String)
        case UnexpectedContainer(type: LivenStructType)

    }

    public var inboundTransfers = PassthroughSubject<AnyLivenStruct, Never>()

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

                self.onTransfer(header: header, body: self.body, footer: footer)
            }
        } catch {
            print("Error handling packet: \(error)")
        }
    }

    private func debugDump(header: LivenProto.HeaderPacket, body: Data, footer: LivenProto.FooterPacket) throws {
        let dir = try FileManager.default.url(
            for: .itemReplacementDirectory,
               in: .userDomainMask,
               appropriateFor: URL(fileURLWithPath: "/Users/"),
               create: true)


        let description = """
          Header:
            unknown: \(header.unknown)
          Checksum: \(footer.checksum)
        """

        try description.write(
            to: dir.appendingPathComponent("summary.txt"),
            atomically: true,
            encoding: .utf8
        )

        let patch = dir.appendingPathComponent("body.bin")
        try body.write(to: patch)

        print("Exported debug dump to \(dir)")

        try Process.run(
            URL(fileURLWithPath: "/nix/store/bkp2nl65nbzjkvg2nypxxdjns7c13g8p-bash-5.1-p8/bin/bash"),
            arguments: [
                "/nix/store/vmdvgws6qp0gav4yrfk72y26dyqpm7qw-python3-3.9.6-env/bin/python3",
                "/Users/lorne/src/liven-xfm/firmware/bank.py",
                patch.path,
            ],
            terminationHandler: nil)
    }

    private func onTransfer(header: LivenProto.HeaderPacket, body: Data, footer: LivenProto.FooterPacket) {
        do {
            do {
                print("onTransfer: decoding received container")
                try debugDump(header: header, body: body, footer: footer)
            } catch {
                print("Debug dump failed")
            }

            // TODO: peek?
            let type = try LivenReader(withData: body).readInt(UInt32.self)

            guard let container = LivenStructType.fromFourCC(type) else {
                throw ReceiverError.UnknownContainer(type: LivenProto.fourCCToString(type))
            }

            guard let initVal = container.initVal else {
                throw ReceiverError.UnexpectedContainer(type: container)
            }

            let checksum = self.checksum(initVal: initVal, buf: body)
            if footer.checksum != checksum {
                print("Warning: checksum failure")
                // throw ReceiverError.ChecksumMismatch(expected: footer.checksum, actual: checksum)
            }

            inboundTransfers.send(try container.decode(withData: body))
        } catch {
            print("Received transfer but could not decode patch: \(error)")
        }
    }

    private func checksum(initVal: UInt32, buf: Data) -> UInt32 {
        return buf.withUnsafeBytes { (p: UnsafePointer<Bytef>) -> UInt32 in
            // This may seem like a magic constant, but it's more likely a constant prefix
            // that I have yet determine.
            return UInt32(crc32(uLong(initVal), p, UInt32(buf.count)))
        }
    }
}
