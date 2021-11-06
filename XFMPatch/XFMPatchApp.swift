//
//  XFMPatchApp.swift
//  XFMPatch
//
//  Created by Andrew Childs on 2021/10/31.
//

import SwiftUI

@main
struct XFMPatchApp: App {
    @StateObject var midiProvider = MIDIProvider()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(midiProvider)
        }
    }
}
