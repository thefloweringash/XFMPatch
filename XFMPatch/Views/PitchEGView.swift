import SwiftUI

struct PEGLevelShower: View {
    @ObservedObject public var envelope: PitchEnvelope

    var body: some View {
        VStack {
            Text("L1: \(envelope.L1), T1: \(envelope.T1)")
            Text("L2: \(envelope.L2), T2: \(envelope.T2)")
            Text("L3: \(envelope.L3), T3: \(envelope.T3)")
            Text("L4: \(envelope.L4), T4: \(envelope.T4)")
        }
    }
}

struct PitchEGView: View {
    @ObservedObject public var eg: PitchEG

    var body: some View {
        VStack {
            HStack {
                EnvelopeEditor(envelope: eg.envelope, levelMin: -48, levelMax: 48)
                PEGLevelShower(envelope: eg.envelope).frame(width: 100, height: 100)
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
