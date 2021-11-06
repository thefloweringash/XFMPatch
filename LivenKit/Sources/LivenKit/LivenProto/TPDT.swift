extension LivenProto {
    public class TPDT {
        public var boop1: UInt32
        public var boop2: UInt32
        public var boop3: UInt32

        public var fixed: (Fixed, Fixed, Fixed, Fixed)
        public var ratio: (Ratio, Ratio, Ratio, Ratio)
        public var envelope: (Envelope, Envelope, Envelope, Envelope)

        public var boop4: UInt32
        public var boop5: UInt32

        public var scale: (Scale, Scale, Scale, Scale)

        init(withReader outerReader: LivenReader) throws {
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

            boop4 = try r.readUInt(UInt32.self)
            boop5 = try r.readUInt(UInt32.self)

            scale.0 = try Scale(withReader: r)
            scale.1 = try Scale(withReader: r)
            scale.2 = try Scale(withReader: r)
            scale.3 = try Scale(withReader: r)
        }
    }

}
