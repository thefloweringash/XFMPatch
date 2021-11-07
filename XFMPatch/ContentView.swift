//
//  ContentView.swift
//  XFMPatch
//
//  Created by Andrew Childs on 2021/10/31.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject public var midiProvider: MIDIProvider
    @EnvironmentObject public var patchStorage: PatchStorage

    var body: some View {
        VStack {
            HStack {
                Picker("MIDI Port", selection: $midiProvider.selectedPort) {
                    Text("None").tag(nil as Int?)
                    ForEach(midiProvider.ports) { port in
                        Text(port.name).tag(port.id as Int?)
                    }
                }
//                Button("Engage") {
//                    let generated = patch.convertToLiven()
//                    debugPrint(generated)
//                }
            }

            NavigationView() {
                List(patchStorage.data) { p in
                    switch p {
                    case .Bank(let bank, serial: _):
                        DisclosureGroup(bank.name) {
                            ForEach(bank.patches) { patch in
                                NavigationLink(patch.name) {
                                    PatchView(patch: patch)
                                }
                            }
                        }
                    case .Patch(let patch, serial: _):
                        NavigationLink(patch.name) {
                            PatchView(patch: patch)
                        }
                    }
                }
                Text("there")
                // PatchView(patch: patch)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
