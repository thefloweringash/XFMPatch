import Foundation
import Combine

class LivenReceiver {
    enum State {
        case Waiting
        case ReadingBody
    }

    enum PacketType: UInt8 {
        case Header = 0x1
        case Body = 0x2
        case Footer = 0x3
    }

    enum ReceiverError: Error {
        case UnmatchedFooter
        case UnmatchedBody
    }

    public var receivedPatch = CurrentValueSubject<FMTC?, Never>(nil)

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

    private var header: HeaderPacket?
    private var body = Data()

    private func onPacket(_ packet: Data) throws {
        // print("onPacket(\(self.hex(packet))")

        let reader = Reader(withData: packet)

        // Constant header
        try reader.skip(bytes: 6)

        switch try reader.readType() {
        case .Header:
            self.header = try HeaderPacket.init(fromReader: reader)
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
            let footer = try FooterPacket(fromReader: reader)
            try self.onTransfer(header: header, body: self.body, footer: footer)
        }
    }


    private func onTransfer(header: HeaderPacket, body: Data, footer: FooterPacket) throws {
        let reader = Reader(withData: body)
        let fmtc = try FMTC(withReader: reader)
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


    // TODO: there must be a standard one of these somewhere
    class Reader {
        enum ReaderError: Error {
            case Underflow
            case UnknownPacket
            case InvalidFourCC
            case FourCCMismatch
            case InvalidString
            case IntegerOverflow
        }

        private var buffer: Data
        init(withData data: Data) {
            self.buffer = data
        }

        public func readUInt<T: UnsignedInteger>(_ type: T.Type) throws -> T {
            return try readUInt(type: type, size: MemoryLayout<T>.size)
        }

        // Convert a number of bytes
        public func readUInt<T: UnsignedInteger>(type _: T.Type, size: Int) throws -> T {
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

        public func readInt<T: SignedInteger>(_ type: T.Type) throws -> T where T.Magnitude : UnsignedInteger {
            return T(truncatingIfNeeded: try readUInt(type.Magnitude))
        }

        public func readType() throws -> PacketType {
            guard let result =  PacketType.init(rawValue: try self.readUInt(UInt8.self)) else {
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

        public func containerReader(fourCC expectedFourCCStr: String) throws -> Reader {
            let expectedFourCC = try fourCCToNumber(expectedFourCCStr)
            let actualFourCC = try readUInt(UInt32.self)

            guard actualFourCC == expectedFourCC else {
                throw ReaderError.FourCCMismatch
            }

            let length = Int(try readUInt(UInt32.self) - 8)

            guard buffer.count >= length else {
                throw ReaderError.Underflow
            }

            let subRange = buffer.prefix(length)
            buffer = buffer.advanced(by: length)

            return Reader(withData: subRange)
        }

        public func readPascalString<T: UnsignedInteger>(_ type: T.Type) throws -> String {
            let length = Int(try readUInt(type))
            let body = try read(bytes: length)
            guard let result = String(data: body, encoding: .ascii) else {
                throw ReaderError.InvalidString
            }
            return result
        }

        private func fourCCToNumber(_ fourCC: String) throws -> UInt32 {
            guard fourCC.count == 4 else {
                throw ReaderError.InvalidFourCC
            }

            var result: UInt32 = 0
            for x in fourCC {
                guard let a = x.asciiValue else {
                    throw ReaderError.InvalidFourCC
                }
                result = (result >> 8) | UInt32(a) << 24
            }
            return result
        }

    }

    struct HeaderPacket {
        public var unknown: UInt32
        public var length: UInt32

        init(fromReader reader: Reader) throws {
            unknown = try reader.readUInt(UInt32.self)
            length = try reader.readUInt(UInt32.self)
        }
    }

    struct FooterPacket {
        public var checksum: UInt32
        init(fromReader reader: Reader) throws {
            checksum = try reader.readUInt(UInt32.self)
        }
    }

    class FMNM {
        public var boop1: UInt32
        public var name: String

        init(withReader outerReader: Reader) throws {
            let r = try outerReader.containerReader(fourCC: "FMNM")
            boop1 = try r.readUInt(UInt32.self)
            name = try r.readPascalString(UInt32.self)
        }
    }

    class TPDT {
        class Fixed {
            public var fixed: Bool
            public var frequencyTimes10: UInt32

            var frequency: Float {
                get {
                    return Float(frequencyTimes10) / 10
                }
                set {
                    frequencyTimes10 = UInt32(newValue * 10)
                }
            }

            init(withReader r: Reader) throws {
                fixed = try r.readUInt(UInt8.self) != 0
                frequencyTimes10 = try r.readUInt(type: UInt32.self, size: 3) // UInt24
            }
        }

        class Ratio {
            public var ratioTimes100: UInt16
            public var level: UInt8
            public var detune: Int8

            init(withReader r: Reader) throws {
                ratioTimes100 = try r.readUInt(UInt16.self)
                level = try r.readUInt(UInt8.self)
                detune = try r.readInt(Int8.self)
            }
        }

        class Envelope {
            public var aTime, dTime, sTime, rTime: UInt8
            public var aLevel, dLevel, sLevel, rLevel: UInt8

            init(withReader r: Reader) throws {
                aTime = try r.readUInt(UInt8.self)
                dTime = try r.readUInt(UInt8.self)
                sTime = try r.readUInt(UInt8.self)
                rTime = try r.readUInt(UInt8.self)

                aLevel = try r.readUInt(UInt8.self)
                dLevel = try r.readUInt(UInt8.self)
                sLevel = try r.readUInt(UInt8.self)
                rLevel = try r.readUInt(UInt8.self)
            }
        }

        public var boop1: UInt32
        public var boop2: UInt32
        public var boop3: UInt32

        public var fixed: (Fixed, Fixed, Fixed, Fixed)
        public var ratio: (Ratio, Ratio, Ratio, Ratio)
        public var envelope: (Envelope, Envelope, Envelope, Envelope)

        init(withReader outerReader: Reader) throws {
            let r = try outerReader.containerReader(fourCC: "TPDT")

            boop1 = try r.readUInt(UInt32.self)
            boop2 = try r.readUInt(UInt32.self)
            boop3 = try r.readUInt(UInt32.self)

            fixed.0 = try Fixed(withReader: r)
            fixed.1 = try Fixed(withReader: r)
            fixed.2 = try Fixed(withReader: r)
            fixed.3 = try Fixed(withReader: r)

            ratio.0 = try Ratio(withReader: r)
            ratio.1 = try Ratio(withReader: r)
            ratio.2 = try Ratio(withReader: r)
            ratio.3 = try Ratio(withReader: r)

            envelope.0 = try Envelope(withReader: r)
            envelope.1 = try Envelope(withReader: r)
            envelope.2 = try Envelope(withReader: r)
            envelope.3 = try Envelope(withReader: r)
        }
    }

    class FMTC {
        public var boop1: UInt32
        public var boop2: UInt32
        public var fmnm: FMNM
        public var tpdt: TPDT

        init(withReader outerReader: Reader) throws {
            let r = try outerReader.containerReader(fourCC: "FMTC")

            boop1 = try r.readUInt(UInt32.self)
            boop2 = try r.readUInt(UInt32.self)
            fmnm = try FMNM(withReader: r)
            tpdt = try TPDT(withReader: r)
        }
    }
}
