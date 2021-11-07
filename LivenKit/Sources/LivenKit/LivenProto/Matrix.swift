extension LivenProto {
    public class Matrix {
        public typealias OperatorLevels = (
            (Int8, UInt8, UInt8, UInt8),
            (UInt8, Int8, UInt8, UInt8),
            (UInt8, UInt8, Int8, UInt8),
            (UInt8, UInt8, UInt8, Int8)
        )

        public typealias MixerLevels = PerOp<UInt8>

        public var operatorLevels: OperatorLevels
        public var mixerLevels: MixerLevels

        init(withReader r: LivenReader) throws {
            operatorLevels.0.0 = try r.readInt(Int8.self)
            operatorLevels.0.1 = try r.readInt(UInt8.self)
            operatorLevels.0.2 = try r.readInt(UInt8.self)
            operatorLevels.0.3 = try r.readInt(UInt8.self)

            operatorLevels.1.0 = try r.readInt(UInt8.self)
            operatorLevels.1.1 = try r.readInt(Int8.self)
            operatorLevels.1.2 = try r.readInt(UInt8.self)
            operatorLevels.1.3 = try r.readInt(UInt8.self)

            operatorLevels.2.0 = try r.readInt(UInt8.self)
            operatorLevels.2.1 = try r.readInt(UInt8.self)
            operatorLevels.2.2 = try r.readInt(Int8.self)
            operatorLevels.2.3 = try r.readInt(UInt8.self)

            operatorLevels.3.0 = try r.readInt(UInt8.self)
            operatorLevels.3.1 = try r.readInt(UInt8.self)
            operatorLevels.3.2 = try r.readInt(UInt8.self)
            operatorLevels.3.3 = try r.readInt(Int8.self)

            mixerLevels = try perOp { try r.readInt(UInt8.self) }
        }

        public init(
            operatorLevels: OperatorLevels,
            mixerLevels: MixerLevels
        ) {
            self.operatorLevels = operatorLevels
            self.mixerLevels = mixerLevels
        }
    }
}
