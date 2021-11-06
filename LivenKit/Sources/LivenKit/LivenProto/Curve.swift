extension LivenProto {
    public class Curve {
        public var up: Int8
        public var down: Int8

        init(withReader r: LivenReader) throws {
            up = try r.readInt(Int8.self)
            down = try r.readInt(Int8.self)
        }

        public init(up: Int8, down: Int8) {
            self.up = up
            self.down = down
        }
    }
}
