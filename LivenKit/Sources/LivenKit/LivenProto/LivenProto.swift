public struct LivenProto {
    enum ProtoError: Error {
        case InvalidFourCC
    }

    public static func fourCCToNumber(_ fourCC: String) throws -> UInt32 {
        guard fourCC.count == 4 else {
            throw ProtoError.InvalidFourCC
        }

        var result: UInt32 = 0
        for x in fourCC {
            guard let a = x.asciiValue else {
                throw ProtoError.InvalidFourCC
            }
            result = (result >> 8) | UInt32(a) << 24
        }
        return result
    }

    public static func fourCCToString(_ fourCC: UInt32) -> String {
        String(format: "%c%c%c%c",
               (fourCC) & 0xff,
               (fourCC >> 8) & 0xff,
               (fourCC >> 16) & 0xff,
               (fourCC >> 24) & 0xff)
    }


    struct HeaderPacket {
        public var unknown: UInt32
        public var length: UInt32

        init(fromReader reader: LivenReader) throws {
            unknown = try reader.readUInt(UInt32.self)
            length = try reader.readUInt(UInt32.self)
        }
    }

    struct FooterPacket {
        public var checksum: UInt32
        init(fromReader reader: LivenReader) throws {
            checksum = try reader.readUInt(UInt32.self)
        }
    }

    public class FMTC {
        public var boop1: UInt32
        public var boop2: UInt32
        public var fmnm: FMNM
        public var tpdt: TPDT

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: "FMTC")

            boop1 = try r.readUInt(UInt32.self)
            boop2 = try r.readUInt(UInt32.self)
            fmnm = try FMNM(withReader: r)
            tpdt = try TPDT(withReader: r)
        }
    }
}
