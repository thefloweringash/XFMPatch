import SwiftUI

struct OperatorEnvelopeEditor: View {
    @ObservedObject public var openv: OperatorEnvelope

    var body: some View {
        let envelope = openv.envelope
        HStack {
            EnvelopeEditor(envelope: openv.envelope)

            VStack {
                Text("L1: \(envelope.L1), T1: \(envelope.T1)")
                Text("L2: \(envelope.L2), T2: \(envelope.T2)")
                Text("L3: \(envelope.L3), T3: \(envelope.T3)")
                Text("L4: \(envelope.L4), T4: \(envelope.T4)")
                Text("Up: \(openv.upCrv), Down: \(openv.downCrv)")
                Text("Timescale: \(openv.timescale)")
            }.frame(width: 100, height: 100)
        }
    }
}


struct OperatorEnvelopeEditor_Previews: PreviewProvider {
    static var previews: some View {
        OperatorEnvelopeEditor(openv: OperatorEnvelope())
    }
}
