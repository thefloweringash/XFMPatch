extension LivenProto {
    public class Fixed {
        public var fixed: Bool
        public var frequencyTimes10: UInt32

        public var frequency: Float {
            get {
                return Float(frequencyTimes10) / 10
            }
            set {
                frequencyTimes10 = UInt32(newValue * 10)
            }
        }

        init(withReader r: LivenReader) throws {
            fixed = try r.readUInt(UInt8.self) != 0
            frequencyTimes10 = try r.readUInt(type: UInt32.self, size: 3) // UInt24
        }
    }
}
