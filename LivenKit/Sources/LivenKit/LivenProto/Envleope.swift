extension LivenProto {
    public class Envelope {
        public var aTime, dTime, sTime, rTime: UInt8
        public var aLevel, dLevel, sLevel, rLevel: UInt8

        init(withReader r: LivenReader) throws {
            aTime = try r.readUInt(UInt8.self)
            dTime = try r.readUInt(UInt8.self)
            sTime = try r.readUInt(UInt8.self)
            rTime = try r.readUInt(UInt8.self)

            aLevel = try r.readUInt(UInt8.self)
            dLevel = try r.readUInt(UInt8.self)
            sLevel = try r.readUInt(UInt8.self)
            rLevel = try r.readUInt(UInt8.self)
        }

        public init(
            aTime: UInt8,
            dTime: UInt8,
            sTime: UInt8,
            rTime: UInt8,
            aLevel: UInt8,
            dLevel: UInt8,
            sLevel: UInt8,
            rLevel: UInt8
        ) {
            self.aTime = aTime
            self.dTime = dTime
            self.sTime = sTime
            self.rTime = rTime

            self.aLevel = aLevel
            self.dLevel = dLevel
            self.sLevel = sLevel
            self.rLevel = rLevel
        }
    }
}
