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
        NavigationView() {
            List(patchStorage.data) { p in
                switch p {
                case .Bank(let bank, serial: _):
                    DisclosureGroup(bank.name) {
                        ForEach(bank.patches) { patch in
                            NavigationLink(patch.name) {
                                PatchView(patch: patch).navigationTitle(patch.name)
                            }
                        }
                    }
                case .Patch(let patch, serial: _):
                    NavigationLink(patch.name) {
                        PatchView(patch: patch).navigationTitle(patch.name)
                    }
                }
            }
            Text("Select a patch")
        }.toolbar {
            Picker("MIDI Port", selection: $midiProvider.selectedPort) {
                Text("None").tag(nil as Int?)
                ForEach(midiProvider.ports) { port in
                    Text(port.name).tag(port.id as Int?)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
