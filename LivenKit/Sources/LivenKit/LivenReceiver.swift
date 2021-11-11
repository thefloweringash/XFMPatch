import Foundation
import Combine

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
        case HeaderMismatch(expected: Data, actual: Data)
    }

    public var inboundTransfers = PassthroughSubject<AnyLivenStruct, Never>()

    public init() {
        
    }

    // MARK: - Reading Bytes

    private var buffer = Data()
    private var state: State = .Waiting
    private var inMessage = false

    public func onBytes<T: Collection>(_ bytes: T) where T.Element == UInt8, T.Index == Int {
        // print("onBytes(\(self.hex(bytes))")

        var base: T.SubSequence = bytes.suffix(from: 0)
        while !base.isEmpty {
            if (!inMessage) {
                // Must be an 0xF0 to trigger anything
                guard base.first == 0xF0 else { return }
                inMessage = true
                buffer = Data()
            }

            if let endOfMessage = base.firstIndex(of: 0xF7) {
                buffer.append(contentsOf: base.prefix(through: endOfMessage))

                self.onUnpackedPacket(buffer)

                buffer = Data()
                inMessage = false
                base = base.suffix(from: endOfMessage + 1)
            } else {
                buffer.append(contentsOf: base)
                return
            }
        }
    }

    internal func combineHighBits<T: Collection>(_ data: T) -> Data where T.Element == UInt8 {
        var buf = Data.init()

        var base = data.dropFirst(0)

        while !base.isEmpty {
            let chunk = base.prefix(8)
            guard var highBits: UInt8 = chunk.first else { break }

            highBits <<= 1

            let packed = chunk.dropFirst().map { (x: UInt8) -> UInt8 in
                let result: UInt8 = x | (highBits & 0x80)
                highBits <<= 1
                return result
            }

            buf.append(contentsOf: packed)

            base = base.dropFirst(8)
        }

        return buf
    }

    private func onUnpackedPacket<T: Collection>(_ bytes: T) where T.Element == UInt8 {
        // print("onUnpackedPacket(\(self.hex(bytes))")

        let base = bytes.dropFirst().prefix { $0 != 0xf7 }
        self.onPacket(combineHighBits(base))
    }

    // MARK: - Reading Packets

    private var header: LivenProto.HeaderPacket?
    private var body = Data()

    private func onPacket(_ packet: Data) {
        do {
            // print("onPacket(\(self.hex(packet))")

            let reader = LivenReader(withData: packet)

            // Constant header
            let header = try reader.read(bytes: 6)
            guard header == LivenPacketHeader else {
                throw ReceiverError.HeaderMismatch(expected: LivenPacketHeader, actual: header)
            }

            switch try reader.readType() {
            case .Header:
                self.header = try LivenProto.HeaderPacket.init(withReader: reader)
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
                let footer = try LivenProto.FooterPacket(withReader: reader)

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

        print(description)

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

    // MARK: - Handling completed transfers

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

            let checksum = checksum(initVal: initVal, buf: body)
            if footer.checksum != checksum {
                throw ReceiverError.ChecksumMismatch(expected: footer.checksum, actual: checksum)
            }

            inboundTransfers.send(try container.decode(withData: body))
        } catch {
            print("Received transfer but could not decode patch: \(error)")
        }
    }

}
