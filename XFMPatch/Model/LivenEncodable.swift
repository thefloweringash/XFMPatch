protocol LivenEncodable {
    associatedtype LivenEncodeType

    func convertToLiven() -> LivenEncodeType
}
