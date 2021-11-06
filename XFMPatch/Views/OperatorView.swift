import SwiftUI

struct OperatorEditor: View {
    @ObservedObject public var op: Operator

    var body: some View {
        VStack {
            EnvelopeEditor(envelope: op.envelope)

            Text("Ratio: \(op.ratio)")
            Text("Level: \(op.level)")
            Text("Fixed: \(String(describing: op.fixed))")
            Text("Frequency: \(op.frequency)")

            ScaleView(scale: op.scale)
        }
    }
}
