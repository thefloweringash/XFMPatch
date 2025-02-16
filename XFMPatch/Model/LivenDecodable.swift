protocol LivenDecodable {
    associatedtype LivenDecodeType

    init()
    init(withLiven: LivenDecodeType)
    func updateFrom(liven: LivenDecodeType)
}

extension LivenDecodable {
    init(withLiven liven: LivenDecodeType) {
        self.init()
        updateFrom(liven: liven)
    }
}
