import SwiftUI

struct OperatorEnvelopeEditor: View {
    @ObservedObject public var openv: OperatorEnvelope
    @ObservedObject public var envelope: AmpEnvelope

    init(openv: OperatorEnvelope) {
        self.openv = openv
        self.envelope = openv.envelope
    }

    var body: some View {
        VStack {
            EnvelopeEditor(envelope: openv.envelope, levelMin: 0, levelMax: 127)

            VStack {
                HStack {
                    Group {
                        Text("L1")
                        IntKnob(range: 0...127, size: .Small, value: $envelope.L1)
                    }
                    Group {
                        Text("L2")
                        IntKnob(range: 0...127, size: .Small, value: $envelope.L2)
                    }
                    Group {
                        Text("L3")
                        IntKnob(range: 0...127, size: .Small, value: $envelope.L3)
                    }
                    Group {
                        Text("L4")
                        IntKnob(range: 0...127, size: .Small, value: $envelope.L4)
                    }
                }
                HStack {
                    Group {
                        Text("T1")
                        IntKnob(range: 0...127, size: .Small, value: $envelope.T1)
                    }
                    Group {
                        Text("T2")
                        IntKnob(range: 0...127, size: .Small, value: $envelope.T2)
                    }
                    Group {
                        Text("T3")
                        IntKnob(range: 0...127, size: .Small, value: $envelope.T3)
                    }
                    Group {
                        Text("T4")
                        IntKnob(range: 0...127, size: .Small, value: $envelope.T4)
                    }
                }
                HStack {
                    Group {
                        Text("up crv")
                        IntKnob(range: -18...18, size: .Small, value: $openv.upCrv)
                    }
                    Group {
                        Text("down crv")
                        IntKnob(range: -18...18, size: .Small, value: $openv.downCrv)
                    }
                    Group {
                        Text("timescale")
                        IntKnob(range: 0...127, size: .Small, value: $openv.timescale)
                    }
                }
            }
        }
    }
}


struct OperatorEnvelopeEditor_Previews: PreviewProvider {
    static var previews: some View {
        OperatorEnvelopeEditor(openv: OperatorEnvelope())
    }
}
