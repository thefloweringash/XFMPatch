extension LivenProto {
    public class FMNM {
        public var boop1: UInt32 = 0
        public var name: String

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: "FMNM")
            boop1 = try r.readUInt(UInt32.self)
            name = try r.readPascalString(UInt32.self)
        }

        public init(name: String) {
            self.name = name
        }
    }
}
