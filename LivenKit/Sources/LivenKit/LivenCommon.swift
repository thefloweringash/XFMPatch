import Foundation
import zlib

public enum LivenPacketType: UInt8, LivenWritable {
    case Header = 0x1
    case Body = 0x2
    case Footer = 0x3

    public func write(toWriter w: LivenWriter) throws {
        try w.writeInt(rawValue)
    }
}

public let LivenPacketHeader: Data = Data.init(base64Encoded: "SAQAAANg")!

public enum AnyLivenPacket: LivenWritable {
    case Header(_: LivenProto.HeaderPacket)
    case Body(_: Data)
    case Footer(_: LivenProto.FooterPacket)

    public var packetType: LivenPacketType {
        switch self {
        case .Header:
            return .Header
        case .Body:
            return .Body
        case .Footer:
            return .Footer
        }
    }

    public func write(toWriter w: LivenWriter) throws {
        w.writeBytes(LivenPacketHeader)
        try packetType.write(toWriter: w)

        switch self {
        case let .Header(h): try h.write(toWriter: w)
        case let .Body(b): w.writeBytes(b)
        case let .Footer(f): try f.write(toWriter: w)
        }
    }

}

public protocol LivenWritable {
    func write(toWriter w: LivenWriter) throws -> Void
}

extension LivenWritable {
    func toData() throws -> Data {
        let livenWriter = LivenWriter()
        try write(toWriter: livenWriter)
        return livenWriter.get()
    }
}

public protocol LivenReadable {
    init(withReader r: LivenReader) throws
}

public protocol LivenCodable: LivenWritable, LivenReadable {

}

public enum AnyLivenStruct {
    case Name(_: LivenProto.FMNM)
    case BankContainer(_: LivenProto.FMBC)
    case TemplateContainer(_: LivenProto.FMTC)
    case BankData(_: LivenProto.BKDT)
    case TemplateData(_: LivenProto.TPDT)

    func toWritable() -> LivenWritable {
        switch self {
        case let .Name(fmnm):
            return fmnm
        case let .BankContainer(fmbc):
            return fmbc
        case let .TemplateContainer(fmtc):
            return fmtc
        case let .BankData(bkdt):
            return bkdt
        case let .TemplateData(tpdt):
            return tpdt
        }
    }

    func structType() -> LivenStructType {
        switch self {
        case .Name:
            return .Name
        case .BankContainer:
            return .BankContainer
        case .TemplateContainer:
            return .TemplateContainer
        case .BankData:
            return .BankData
        case .TemplateData:
            return .TemplateData
        }
    }
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

    var headerUnknown: UInt32? {
        switch self {
        case .TemplateContainer:
            return 0
        case .BankContainer:
            return 1
        default:
             return nil
        }
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

func checksum(initVal: UInt32, buf: Data) -> UInt32 {
    return buf.withUnsafeBytes { (p: UnsafePointer<Bytef>) -> UInt32 in
        // This may seem like a magic constant, but it's more likely a constant prefix
        // that I have yet determine.
        return UInt32(crc32(uLong(initVal), p, UInt32(buf.count)))
    }
}
