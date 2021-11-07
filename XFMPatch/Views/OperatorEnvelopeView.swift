import SwiftUI

struct OperatorEnvelopeEditor: View {
    @ObservedObject public var openv: OperatorEnvelope
    @ObservedObject public var envelope: AmpEnvelope

    init(openv: OperatorEnvelope) {
        self.openv = openv
        self.envelope = openv.envelope
    }

    var body: some View {
        HStack {
            EnvelopeEditor(envelope: openv.envelope, levelMin: 0, levelMax: 127)

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
