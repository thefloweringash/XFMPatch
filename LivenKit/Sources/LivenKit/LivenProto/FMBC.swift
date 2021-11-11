extension LivenProto {
    public struct FMBC: LivenWritable {
        static let containerName = "FMBC"

        public var boop1: UInt32 = 0
        public var boop2: UInt32 = 2
        public var fmnm: FMNM
        public var bkdt: BKDT

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: Self.containerName)

            boop1 = try r.readInt(UInt32.self)
            boop2 = try r.readInt(UInt32.self)
            fmnm = try FMNM(withReader: r)
            bkdt = try BKDT(withReader: r)
        }

        public func write(toWriter outer: LivenWriter) throws {
            try outer.writeContainer(fourCC: Self.containerName) { w in
                try w.writeInt(boop1)
                try w.writeInt(boop2)
                try fmnm.write(toWriter: w)
                try bkdt.write(toWriter: w)
            }
        }

        public init(fmnm: FMNM, bkdt: BKDT) {
            self.fmnm = fmnm
            self.bkdt = bkdt
        }
    }
}
