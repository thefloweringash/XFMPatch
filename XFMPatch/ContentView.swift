//
//  ContentView.swift
//  XFMPatch
//
//  Created by Andrew Childs on 2021/10/31.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject public var midiProvider: MIDIProvider
    @StateObject public var patch = Patch()

    init() {
        
    }

    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()

            Picker("MIDI Port", selection: $midiProvider.selectedPort) {
                Text("None").tag(nil as Int?)
                ForEach(midiProvider.ports) { port in
                    Text(port.name).tag(port.id as Int?)
                }
            }

            Text("Selected \(String(describing: midiProvider.selectedPort))")

            PatchEditor(patch: patch)
                .padding(18)
        }.onReceive(midiProvider.receivedPatch, perform: { newPatch in
            guard let newPatch = newPatch else { return }
            patch.op1.envelope.L1 = Int(newPatch.tpdt.envelope.0.aLevel)
            patch.op1.envelope.L2 = Int(newPatch.tpdt.envelope.0.dLevel)
            patch.op1.envelope.L3 = Int(newPatch.tpdt.envelope.0.sLevel)
            patch.op1.envelope.L4 = Int(newPatch.tpdt.envelope.0.rLevel)

            patch.op1.envelope.T1 = Int(newPatch.tpdt.envelope.0.aTime)
            patch.op1.envelope.T2 = Int(newPatch.tpdt.envelope.0.dTime)
            patch.op1.envelope.T3 = Int(newPatch.tpdt.envelope.0.sTime)
            patch.op1.envelope.T4 = Int(newPatch.tpdt.envelope.0.rTime)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
