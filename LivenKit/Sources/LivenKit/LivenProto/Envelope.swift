public extension LivenProto {
    struct Envelope<T>: LivenWritable where T: FixedWidthInteger {
        public var times: PerOp<UInt8>
        public var levels: PerOp<T>

        init(withReader r: LivenReader) throws {
            times = try perOp { try r.readInt(UInt8.self) }
            levels = try perOp { try r.readInt(T.self) }
        }

        public func write(toWriter w: LivenWriter) throws {
            try forEachOp(times) { try w.writeInt($0) }
            try forEachOp(levels) { try w.writeInt($0) }
        }

        public init(
            times: PerOp<UInt8>,
            levels: PerOp<T>
        ) {
            self.times = times
            self.levels = levels
        }
    }

    typealias PitchEnvelope = Envelope<Int8>
    typealias AmpEnvelope = Envelope<UInt8>
}
