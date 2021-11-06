struct LivenProto {
    struct HeaderPacket {
        public var unknown: UInt32
        public var length: UInt32

        init(fromReader reader: LivenReader) throws {
            unknown = try reader.readUInt(UInt32.self)
            length = try reader.readUInt(UInt32.self)
        }
    }

    struct FooterPacket {
        public var checksum: UInt32
        init(fromReader reader: LivenReader) throws {
            checksum = try reader.readUInt(UInt32.self)
        }
    }

    class FMNM {
        public var boop1: UInt32
        public var name: String

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: "FMNM")
            boop1 = try r.readUInt(UInt32.self)
            name = try r.readPascalString(UInt32.self)
        }
    }

    class TPDT {
        class Fixed {
            public var fixed: Bool
            public var frequencyTimes10: UInt32

            var frequency: Float {
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

        class Ratio {
            public var ratioTimes100: UInt16
            public var level: UInt8
            public var detune: Int8

            var ratio: Float {
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

        class Envelope {
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
        }

        class Scale {
            enum ScaleError: Error {
                case InvalidCurves
            }

            enum CurveType: UInt8, CaseIterable, Identifiable {
                case Linear = 0
                case Exponential = 1

                var id: UInt8 {
                    get {
                        self.rawValue
                    }
                }
            }

            public var lGain: Int8
            public var rGain: Int8
            public var curvesPacked: UInt8
            public var scalePos: UInt8

            public var lCurve: CurveType {
                get {
                    tryLCurve!
                }
                set {
                    curvesPacked = (curvesPacked & 0xf0) | newValue.rawValue
                }
            }

            public var rCurve: CurveType {
                get {
                    tryRCurve!
                }
                set {
                    curvesPacked = (curvesPacked & 0xf) | (newValue.rawValue << 4)
                }
            }

            init(withReader r: LivenReader) throws {
                lGain = try r.readInt(Int8.self)
                rGain = try r.readInt(Int8.self)
                curvesPacked = try r.readUInt(UInt8.self)
                scalePos = try r.readUInt(UInt8.self)

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

        public var boop1: UInt32
        public var boop2: UInt32
        public var boop3: UInt32

        public var fixed: (Fixed, Fixed, Fixed, Fixed)
        public var ratio: (Ratio, Ratio, Ratio, Ratio)
        public var envelope: (Envelope, Envelope, Envelope, Envelope)

        public var boop4: UInt32
        public var boop5: UInt32

        public var scale: (Scale, Scale, Scale, Scale)


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
        }
    }

    class FMTC {
        public var boop1: UInt32
        public var boop2: UInt32
        public var fmnm: FMNM
        public var tpdt: TPDT

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: "FMTC")

            boop1 = try r.readUInt(UInt32.self)
            boop2 = try r.readUInt(UInt32.self)
            fmnm = try FMNM(withReader: r)
            tpdt = try TPDT(withReader: r)
        }
    }
}
