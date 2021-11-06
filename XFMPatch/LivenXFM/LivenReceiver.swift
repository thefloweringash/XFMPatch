import Foundation
import Combine

enum LivenPacketType: UInt8 {
    case Header = 0x1
    case Body = 0x2
    case Footer = 0x3
}

class LivenReceiver {
    enum State {
        case Waiting
        case ReadingBody
    }

    enum ReceiverError: Error {
        case UnmatchedFooter
        case UnmatchedBody
    }

    public var receivedPatch = CurrentValueSubject<LivenProto.FMTC?, Never>(nil)

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

        try! self.onPacket(buf)
    }

    // MARK: Reading Packets

    private var header: LivenProto.HeaderPacket?
    private var body = Data()

    private func onPacket(_ packet: Data) throws {
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
            try self.onTransfer(header: header, body: self.body, footer: footer)
        }
    }


    private func onTransfer(header: LivenProto.HeaderPacket, body: Data, footer: LivenProto.FooterPacket) throws {
        let reader = LivenReader(withData: body)
        let fmtc = try LivenProto.FMTC(withReader: reader)
        receivedPatch.send(fmtc)
    }


    /*
    private func onTransferDecodeWithHacks(header: HeaderPacket, body: Data, footer: FooterPacket) throws {
        print("onTransfer: \(header) \(body) \(footer)")

        do {
            let dir = try FileManager.default.url(
                for: .itemReplacementDirectory,
                   in: .userDomainMask,
                   appropriateFor: URL(fileURLWithPath: "/Users/lorne/"),
                   create: true)

            let patch = dir.appendingPathComponent("patch.bin")
            try body.write(to: patch)

            print("Exported patch to \(patch.absoluteString)")

            try Process.run(
                URL(fileURLWithPath: "/nix/store/bkp2nl65nbzjkvg2nypxxdjns7c13g8p-bash-5.1-p8/bin/bash"),
                arguments: [
                    "/nix/store/vmdvgws6qp0gav4yrfk72y26dyqpm7qw-python3-3.9.6-env/bin/python3",
                    "/Users/lorne/src/liven-xfm/firmware/bank.py",
                    patch.path,
                ],
                terminationHandler: nil)
        }
        catch {
            print("Decode failed: \(error)")
        }
    }
     */

    private func hex<T: Collection>(_ bytes: T) -> String where T.Element == UInt8 {
        return bytes.map { String(format: "0x%.2x", $0) }.joined(separator: " ")
    }

    private func chrs<T: Collection>(_ bytes: T) -> String where T.Element == UInt8 {
        return bytes.map { String(format: "0x%.2c", $0) }.joined(separator: " ")
    }

}
