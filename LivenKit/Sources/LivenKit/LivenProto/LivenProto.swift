public enum LivenProto {
    public typealias PerOp<T> = (T, T, T, T)

    public static func perOp<T>(f: () throws -> T) rethrows -> PerOp<T> {
        try (
            f(),
            f(),
            f(),
            f()
        )
    }

    public static func mapPerOp<T, U>(_ x: PerOp<T>, f: (_: T) -> U) -> PerOp<U> {
        (
            f(x.0),
            f(x.1),
            f(x.2),
            f(x.3)
        )
    }

    public static func forEachOp<T>(_ x: PerOp<T>, f: (_: T) throws -> Void) rethrows {
        try f(x.0)
        try f(x.1)
        try f(x.2)
        try f(x.3)
    }

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
               fourCC & 0xFF,
               (fourCC >> 8) & 0xFF,
               (fourCC >> 16) & 0xFF,
               (fourCC >> 24) & 0xFF)
    }

    public struct HeaderPacket: LivenCodable {
        public var unknown: UInt32
        public var length: UInt32

        public init(withReader reader: LivenReader) throws {
            unknown = try reader.readInt(UInt32.self)
            length = try reader.readInt(UInt32.self)
        }

        public func write(toWriter writer: LivenWriter) throws {
            try writer.writeInt(unknown)
            try writer.writeInt(length)
        }

        init(unknown: UInt32, length: UInt32) {
            self.unknown = unknown
            self.length = length
        }
    }

    public struct FooterPacket: LivenCodable {
        public var checksum: UInt32

        public init(withReader reader: LivenReader) throws {
            checksum = try reader.readInt(UInt32.self)
        }

        public func write(toWriter writer: LivenWriter) throws {
            try writer.writeInt(checksum)
        }

        init(checksum: UInt32) {
            self.checksum = checksum
        }
    }
}
