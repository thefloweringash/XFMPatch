public extension LivenProto {
    struct BKDT: LivenWritable {
        static let containerName = "BKDT"

        enum Errors: Error {
            case InvalidPatchCount
        }

        public var boop1: UInt32 = 0
        public var boop2: UInt32 = 2

        public var patches: [FMTC]

        init(withReader outerReader: LivenReader) throws {
            let r = try outerReader.containerReader(fourCC: Self.containerName)

            boop1 = try r.readInt(UInt32.self)
            boop2 = try r.readInt(UInt32.self)

            patches = try (1...16).map { _ in try FMTC(withReader: r) }
        }

        public func write(toWriter outer: LivenWriter) throws {
            try outer.writeContainer(fourCC: Self.containerName, body: { w in
                try w.writeInt(boop1)
                try w.writeInt(boop2)

                guard patches.count == 16 else {
                    throw Errors.InvalidPatchCount
                }

                for patch in patches {
                    try patch.write(toWriter: w)
                }
            })
        }

        public init(patches: [FMTC]) {
            self.patches = patches
        }
    }
}
