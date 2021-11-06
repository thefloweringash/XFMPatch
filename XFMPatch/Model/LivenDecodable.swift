protocol LivenReceiverDecodable {
    associatedtype LivenReceiverType

    init()
    init(withLiven: LivenReceiverType)
    func updateFrom(liven: LivenReceiverType) -> Void
}

extension LivenReceiverDecodable {
    init(withLiven liven: LivenReceiverType) {
        self.init()
        self.updateFrom(liven: liven)
    }
}
