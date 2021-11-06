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

    var body: some View {
        VStack {
            HStack {
                Picker("MIDI Port", selection: $midiProvider.selectedPort) {
                    Text("None").tag(nil as Int?)
                    ForEach(midiProvider.ports) { port in
                        Text(port.name).tag(port.id as Int?)
                    }
                }
                Button("Engage") {
                    let generated = patch.convertToLiven()
                    debugPrint(generated)
                }
            }

            Spacer(minLength: 18)

            PatchView(patch: patch)

            Spacer()
        }.onReceive(midiProvider.receivedPatch, perform: { newPatch in
            guard let newPatch = newPatch else { return }
            patch.updateFrom(liven: newPatch)
        }).padding(18)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
