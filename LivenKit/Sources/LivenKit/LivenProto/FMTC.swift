extension LivenProto {
    public struct FMTC {
        public var boop1: UInt32 = 0
        public var boop2: UInt32 = 2
        public var fmnm: FMNM
        public var tpdt: TPDT

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: "FMTC")

            boop1 = try r.readInt(UInt32.self)
            boop2 = try r.readInt(UInt32.self)
            fmnm = try FMNM(withReader: r)
            tpdt = try TPDT(withReader: r)
        }

        public init(fmnm: FMNM, tpdt: TPDT) {
            self.fmnm = fmnm
            self.tpdt = tpdt
        }
    }
}
