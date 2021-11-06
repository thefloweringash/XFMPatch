extension LivenProto {
    public class Ratio {
        public var ratioTimes100: UInt16
        public var level: UInt8
        public var detune: Int8
        
        public var ratio: Float {
            get {
                return Float(ratioTimes100) / 100
            }
            set {
                ratioTimes100 = UInt16(newValue * 100)
            }
        }
        
        init(withReader r: LivenReader) throws {
            ratioTimes100 = try r.readUInt(UInt16.self)
            level = try r.readUInt(UInt8.self)
            detune = try r.readInt(Int8.self)
        }
    }
}
