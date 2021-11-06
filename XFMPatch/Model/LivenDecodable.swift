protocol LivenDecodable {
    associatedtype LivenDecodeType

    init()
    init(withLiven: LivenDecodeType)
    func updateFrom(liven: LivenDecodeType) -> Void
}

extension LivenDecodable {
    init(withLiven liven: LivenDecodeType) {
        self.init()
        self.updateFrom(liven: liven)
    }
}
