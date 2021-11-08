extension LivenProto {
    public struct FMBC {
        public var boop1: UInt32 = 0
        public var boop2: UInt32 = 2
        public var fmnm: FMNM
        public var bkdt: BKDT

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: "FMBC")

            boop1 = try r.readInt(UInt32.self)
            boop2 = try r.readInt(UInt32.self)
            fmnm = try FMNM(withReader: r)
            bkdt = try BKDT(withReader: r)
        }

        public init(fmnm: FMNM, bkdt: BKDT) {
            self.fmnm = fmnm
            self.bkdt = bkdt
        }
    }
}
