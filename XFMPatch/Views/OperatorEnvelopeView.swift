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
                        IntKnob(value: $envelope.L1, in: 0...127, resetValue: 127)
                    }
                    Group {
                        Text("L2")
                        IntKnob(value: $envelope.L2, in: 0...127, resetValue: 127)
                    }
                    Group {
                        Text("L3")
                        IntKnob(value: $envelope.L3, in: 0...127, resetValue: 127)
                    }
                    Group {
                        Text("L4")
                        IntKnob(value: $envelope.L4, in: 0...127)
                    }
                }
                HStack {
                    Group {
                        Text("T1")
                        IntKnob(value: $envelope.T1, in: 0...127)
                    }
                    Group {
                        Text("T2")
                        IntKnob(value: $envelope.T2, in: 0...127)
                    }
                    Group {
                        Text("T3")
                        IntKnob(value: $envelope.T3, in: 0...127)
                    }
                    Group {
                        Text("T4")
                        IntKnob(value: $envelope.T4, in: 0...127)
                    }
                }
                HStack {
                    Group {
                        Text("up crv")
                        IntKnob(value: $openv.upCrv, in: -18...18)
                    }
                    Group {
                        Text("down crv")
                        IntKnob(value: $openv.downCrv, in: -18...18)
                    }
                    Group {
                        Text("timescale")
                        IntKnob(value: $openv.timescale, in: 0...127)
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
