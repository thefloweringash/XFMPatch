extension LivenProto {
    public struct Scale {
        enum ScaleError: Error {
            case InvalidCurves
            case InvalidScalePos
        }

        public enum CurveType: UInt8, CaseIterable, Identifiable {
            case Linear = 0
            case Exponential = 1

            public var id: UInt8 {
                get {
                    self.rawValue
                }
            }
        }

        public enum ScalePos: UInt8, CaseIterable, Identifiable, CustomStringConvertible {
            case C1 = 0
            case C2 = 1
            case C3 = 2
            case C4 = 3
            case C5 = 4
            case C6 = 5
            case C7 = 6

            public var id: UInt8 {
                get {
                    self.rawValue
                }
            }

            public var description: String {
                switch self {
                case .C1: return "C1"
                case .C2: return "C2"
                case .C3: return "C3"
                case .C4: return "C4"
                case .C5: return "C5"
                case .C6: return "C6"
                case .C7: return "C7"
                }
            }
        }

        public var lGain: Int8
        public var rGain: Int8
        public var curvesPacked: UInt8
        public var scalePos: ScalePos

        public var lCurve: CurveType {
            get { tryLCurve! }
            set {
                curvesPacked = (curvesPacked & 0xf0) | newValue.rawValue
            }
        }

        public var rCurve: CurveType {
            get { tryRCurve! }
            set {
                curvesPacked = (curvesPacked & 0xf) | (newValue.rawValue << 4)
            }
        }

        public init(
            lGain: Int8,
            rGain: Int8,
            lCurve: CurveType,
            rCurve: CurveType,
            scalePos: ScalePos
        ) {
            self.lGain = lGain
            self.rGain = rGain
            self.curvesPacked = 0
            self.scalePos = scalePos

            self.lCurve = lCurve
            self.rCurve = rCurve
        }

        init(withReader r: LivenReader) throws {
            lGain = try r.readInt(Int8.self)
            rGain = try r.readInt(Int8.self)
            curvesPacked = try r.readInt(UInt8.self)

            guard let parsedScalepos = ScalePos(rawValue: try r.readInt(UInt8.self)) else {
                throw ScaleError.InvalidScalePos
            }
            scalePos = parsedScalepos

            guard tryLCurve != nil && tryRCurve != nil else {
                throw ScaleError.InvalidCurves
            }
        }

        private var tryLCurve: CurveType? {
            CurveType(rawValue: curvesPacked & 0xf)
        }

        private var tryRCurve: CurveType? {
            CurveType(rawValue: curvesPacked >> 4)
        }
    }
}
