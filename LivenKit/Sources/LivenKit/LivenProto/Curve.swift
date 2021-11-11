extension LivenProto {
    public struct Curve: LivenWritable {
        public var up: Int8
        public var down: Int8

        init(withReader r: LivenReader) throws {
            up = try r.readInt(Int8.self)
            down = try r.readInt(Int8.self)
        }

        public func write(toWriter w: LivenWriter) throws {
            try w.writeInt(up)
            try w.writeInt(down)
        }

        public init(up: Int8, down: Int8) {
            self.up = up
            self.down = down
        }
    }
}
