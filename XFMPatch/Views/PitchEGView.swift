import SwiftUI

struct PitchEGView: View {
    @ObservedObject public var eg: PitchEG
    @ObservedObject public var envelope: PitchEnvelope

    init(eg: PitchEG) {
        self.eg = eg
        self.envelope = eg.envelope
    }

    var body: some View {
        VStack {
            EnvelopeEditor(envelope: eg.envelope, levelMin: -48, levelMax: 48)
            HStack {
                Group {
                    Text("L1")
                    IntKnob(range: -48...48, size: .Small, value: $envelope.L1)
                }
                Group {
                    Text("L2")
                    IntKnob(range: -48...48, size: .Small, value: $envelope.L2)
                }
                Group {
                    Text("L3")
                    IntKnob(range: -48...48, size: .Small, value: $envelope.L3)
                }
                Group {
                    Text("L4")
                    IntKnob(range: -48...48, size: .Small, value: $envelope.L4)
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
