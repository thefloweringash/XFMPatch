import SwiftUI

struct PitchEGView: View {
    @ObservedObject public var eg: PitchEG
    @ObservedObject public var envelope: PitchEnvelope

    init(eg: PitchEG) {
        self.eg = eg
        envelope = eg.envelope
    }

    var body: some View {
        VStack {
            EnvelopeEditor(envelope: eg.envelope, levelMin: -48, levelMax: 48)
            HStack {
                Group {
                    Text("L1")
                    IntKnob(value: $envelope.L1, in: -48...48)
                }
                Group {
                    Text("L2")
                    IntKnob(value: $envelope.L2, in: -48...48)
                }
                Group {
                    Text("L3")
                    IntKnob(value: $envelope.L3, in: -48...48)
                }
                Group {
                    Text("L4")
                    IntKnob(value: $envelope.L4, in: -48...48)
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
                Toggle("Op1", isOn: $eg.o1e)
                Toggle("Op2", isOn: $eg.o2e)
                Toggle("Op3", isOn: $eg.o3e)
                Toggle("Op4", isOn: $eg.o4e)
            }
        }
    }
}

struct PitchEGView_Previews: PreviewProvider {
    static var previews: some View {
        PitchEGView(eg: PitchEG())
    }
}
