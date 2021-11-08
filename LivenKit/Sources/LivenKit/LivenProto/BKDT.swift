extension LivenProto {
    public struct BKDT {
        public var boop1: UInt32 = 0
        public var boop2: UInt32 = 2

        public var patches: [FMTC]

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: "BKDT")

            boop1 = try r.readInt(UInt32.self)
            boop2 = try r.readInt(UInt32.self)

            patches = try (1...16).map { _ in try FMTC(withReader: r) }
        }

        public init(patches: [FMTC]) {
            self.patches = patches
        }
    }
}
