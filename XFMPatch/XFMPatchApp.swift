import SwiftUI

@main
struct XFMPatchApp: App {
    @StateObject var midiProvider = MIDIProvider()
    @StateObject var patchStorage = PatchStorage()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(midiProvider)
                .environmentObject(patchStorage)
                .onReceive(midiProvider.receivedStruct) { s in
                    if case let .BankContainer(fmbc) = s {
                        patchStorage.append(bank: Bank(withLiven: fmbc))
                    } else if case let .TemplateContainer(fmtc) = s {
                        patchStorage.append(patch: Patch(withLiven: fmtc))
                    }
                }
        }
    }
}
