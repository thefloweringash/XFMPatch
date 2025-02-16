public extension LivenProto {
    struct Fixed: LivenWritable {
        public var fixed: Bool
        public var frequencyTimes10: UInt32

        public var frequency: Float {
            get {
                Float(frequencyTimes10) / 10
            }
            set {
                frequencyTimes10 = UInt32(newValue * 10)
            }
        }

        init(withReader r: LivenReader) throws {
            fixed = try r.readInt(UInt8.self) != 0
            frequencyTimes10 = try r.readInt(UInt32.self, size: 3) // UInt24
        }

        public func write(toWriter w: LivenWriter) throws {
            try w.writeInt(fixed ? UInt8(1) : UInt8(0))
            try w.writeInt(frequencyTimes10, size: 3)
        }

        public init(fixed: Bool, frequency: Float) {
            self.fixed = fixed
            frequencyTimes10 = 0
            self.frequency = frequency
        }
    }
}
