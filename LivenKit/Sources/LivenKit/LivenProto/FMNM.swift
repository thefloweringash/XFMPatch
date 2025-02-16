public extension LivenProto {
    struct FMNM: LivenWritable {
        static let containerName = "FMNM"

        public var boop1: UInt32 = 0
        public var name: String

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: Self.containerName)
            boop1 = try r.readInt(UInt32.self)
            name = try r.readPascalString(UInt32.self)
        }

        public func write(toWriter outer: LivenWriter) throws {
            try outer.writeContainer(fourCC: Self.containerName, size: 20, pad: 0xFF) { w in
                try w.writeInt(boop1)
                try w.writePascalString(UInt32.self, name)
            }
        }

        public init(name: String) {
            self.name = name
        }
    }
}
