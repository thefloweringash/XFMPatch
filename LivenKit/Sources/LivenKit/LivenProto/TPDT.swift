extension LivenProto {
    public class TPDT {
        public var boop1: UInt32 = 0
        public var boop2: UInt32 = 1
        public var boop3: UInt32 = 0

        public var fixed: PerOp<Fixed>
        public var ratio: PerOp<Ratio>
        public var envelope: PerOp<AmpEnvelope>
        public var pitchEnvelope: PitchEnvelope

        public var scale: PerOp<Scale>

        public var matrix: Matrix

        public var velocity: PerOp<UInt8>
        public var timescale: PerOp<UInt8>
        public var pitchEG: PerOp<UInt8>

        public var curve: PerOp<Curve>

        public var boop6: UInt32 = 0xffffff00

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: "TPDT")

            boop1 = try r.readInt(UInt32.self)
            boop2 = try r.readInt(UInt32.self)
            boop3 = try r.readInt(UInt32.self)

            fixed = try perOp { try Fixed(withReader: r) }
            ratio = try perOp { try Ratio(withReader: r) }
            envelope = try perOp { try Envelope(withReader: r) }

            pitchEnvelope = try Envelope(withReader: r)

            scale = try perOp { try Scale(withReader: r) }

            matrix = try Matrix(withReader: r)

            velocity = try perOp { try r.readInt(UInt8.self) }
            timescale = try perOp { try r.readInt(UInt8.self) }
            pitchEG = try perOp { try r.readInt(UInt8.self) }
            curve = try perOp { try Curve(withReader: r) }

            boop6 = try r.readInt(UInt32.self)

            try r.assertDrained()
        }

        public init(
            fixed: (Fixed, Fixed, Fixed, Fixed),
            ratio: (Ratio, Ratio, Ratio, Ratio),
            envelope: (AmpEnvelope, AmpEnvelope, AmpEnvelope, AmpEnvelope),
            pitchEnvelope: PitchEnvelope,
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
            self.pitchEnvelope = pitchEnvelope
            self.scale = scale
            self.matrix = matrix
            self.velocity = velocity
            self.timescale = timescale
            self.pitchEG = pitchEG
            self.curve = curve
        }
    }
}
