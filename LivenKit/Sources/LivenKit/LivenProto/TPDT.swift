extension LivenProto {
    public class TPDT {
        public var boop1: UInt32 = 0
        public var boop2: UInt32 = 1
        public var boop3: UInt32 = 0

        public var fixed: (Fixed, Fixed, Fixed, Fixed)
        public var ratio: (Ratio, Ratio, Ratio, Ratio)
        public var envelope: (Envelope, Envelope, Envelope, Envelope)

        public var boop4: UInt32 = 0
        public var boop5: UInt32 = 0

        public var scale: (Scale, Scale, Scale, Scale)

        public var matrix: Matrix

        public var velocity: (UInt8, UInt8, UInt8, UInt8)
        public var timescale: (UInt8, UInt8, UInt8, UInt8)
        public var pitchEG: (UInt8, UInt8, UInt8, UInt8)

        public var curve: (Curve, Curve, Curve, Curve)

        public var boop6: UInt32 = 0xffffff00

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

            matrix = try Matrix(withReader: r)

            velocity.0 = try r.readUInt(UInt8.self)
            velocity.1 = try r.readUInt(UInt8.self)
            velocity.2 = try r.readUInt(UInt8.self)
            velocity.3 = try r.readUInt(UInt8.self)

            timescale.0 = try r.readUInt(UInt8.self)
            timescale.1 = try r.readUInt(UInt8.self)
            timescale.2 = try r.readUInt(UInt8.self)
            timescale.3 = try r.readUInt(UInt8.self)

            pitchEG.0 = try r.readUInt(UInt8.self)
            pitchEG.1 = try r.readUInt(UInt8.self)
            pitchEG.2 = try r.readUInt(UInt8.self)
            pitchEG.3 = try r.readUInt(UInt8.self)

            curve.0 = try Curve(withReader: r)
            curve.1 = try Curve(withReader: r)
            curve.2 = try Curve(withReader: r)
            curve.3 = try Curve(withReader: r)

            boop6 = try r.readUInt(UInt32.self)

            try r.assertDrained()
        }

        public init(
            fixed: (Fixed, Fixed, Fixed, Fixed),
            ratio: (Ratio, Ratio, Ratio, Ratio),
            envelope: (Envelope, Envelope, Envelope, Envelope),
            scale: (Scale, Scale, Scale, Scale),
            matrix: Matrix,
            velocity: (UInt8, UInt8, UInt8, UInt8),
            timescale: (UInt8, UInt8, UInt8, UInt8),
            pitchEG: (UInt8, UInt8, UInt8, UInt8),
            curve: (Curve, Curve, Curve, Curve)
        ) {
            self.fixed = fixed
            self.ratio = ratio
            self.envelope = envelope
            self.scale = scale
            self.matrix = matrix
            self.velocity = velocity
            self.timescale = timescale
            self.pitchEG = pitchEG
            self.curve = curve
        }
    }
}
