public extension LivenProto {
    struct TPDT: LivenWritable {
        static let containerName = "TPDT"

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

        public var boop6: UInt32 = 0 // TODO: first byte is pattern level

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: Self.containerName)

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

        public func write(toWriter outer: LivenWriter) throws {
            try outer.writeContainer(fourCC: Self.containerName, size: 152, pad: nil) { w in
                try w.writeInt(boop1)
                try w.writeInt(boop2)
                try w.writeInt(boop3)

                try forEachOp(fixed) { try $0.write(toWriter: w) }
                try forEachOp(ratio) { try $0.write(toWriter: w) }
                try forEachOp(envelope) { try $0.write(toWriter: w) }

                try pitchEnvelope.write(toWriter: w)

                try forEachOp(scale) { try $0.write(toWriter: w) }

                try matrix.write(toWriter: w)

                try forEachOp(velocity) { try w.writeInt($0) }
                try forEachOp(timescale) { try w.writeInt($0) }
                try forEachOp(pitchEG) { try w.writeInt($0) }
                try forEachOp(curve) { try $0.write(toWriter: w) }

                try w.writeInt(boop6)
            }
        }

        public init(
            fixed: PerOp<Fixed>,
            ratio: PerOp<Ratio>,
            envelope: PerOp<AmpEnvelope>,
            pitchEnvelope: PitchEnvelope,
            scale: PerOp<Scale>,
            matrix: Matrix,
            velocity: PerOp<UInt8>,
            timescale: PerOp<UInt8>,
            pitchEG: PerOp<UInt8>,
            curve: PerOp<Curve>
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
