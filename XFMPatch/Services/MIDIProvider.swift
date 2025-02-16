import Combine
import CoreMIDI
import Foundation
import LivenKit

struct MIDIPort: Identifiable {
    var id: Int
    var name: String
}

@MainActor
class MIDIProvider: ObservableObject {
    @Published public var selectedPort: Int? {
        didSet {
            if let selectedPort {
                openPort(selectedPort)
            }
            print("set port to \(String(describing: oldValue)) -> \(String(describing: selectedPort))")
        }
    }

    @Published public var ports: [MIDIPort] = []

    private var midiClient: MIDIClientRef = 0
    private var midiInputPort: MIDIPortRef = 0
    private var midiConnectedSource: MIDIEndpointRef = 0
    private var sourceRef: UnsafeMutableRawPointer = .allocate(byteCount: 1, alignment: 0)

    private var receiver = LivenReceiver()

    private var subscriptions = Set<AnyCancellable>()

    init() {
        initClient()
        enumSources()

        receiver.inboundTransfers.sink { [weak self] s in
            guard let self else { return }
            receivedStruct.send(s)
        }.store(in: &subscriptions)
    }

    deinit {
        MIDIPortDispose(self.midiInputPort)
        MIDIClientDispose(self.midiClient)
    }

    private func initClient() {
        let notifyProc: MIDINotifyBlock = { [weak self] (event: UnsafePointer<MIDINotification>) in
            guard let self else {
                return
            }
            let message = event.pointee.messageID
            if message == .msgObjectAdded || message == .msgObjectRemoved {
                enumSources()
            }
            print("received midi notification: \(String(reflecting: event.pointee.messageID))")
        }

        try! checkOSStatus(
            MIDIClientCreateWithBlock("LivenXFM Patch" as CFString, &midiClient, notifyProc)
        )

        try! checkOSStatus(
            MIDIInputPortCreateWithBlock(midiClient, "Input" as CFString, &midiInputPort) { (events: UnsafePointer<MIDIPacketList>, srcRefCon: UnsafeMutableRawPointer?) in
                for p in events.unsafeSequence() {
                    self.receiver.onBytes(p.bytes())
                }
            }
        )
    }

    private func enumSources() {
        var ports: [MIDIPort] = []

        let sources = MIDIGetNumberOfSources()
        for n in 0...sources {
            let device = MIDIGetSource(n)
            guard device != 0 else {
                continue
            }
            // defer { MIDIEndpointDispose(device) } -- This breaks everything

            let name: UnsafeMutablePointer<Unmanaged<CFString>?> = .allocate(capacity: 1)
            MIDIObjectGetStringProperty(device, kMIDIPropertyName, name)

            if let nameStr = name.pointee?.takeRetainedValue() {
                ports.append(.init(id: n, name: nameStr as String))
            }
        }

        if ports.isEmpty {
            selectedPort = nil
        } else {
            selectedPort = 0
        }

        self.ports = ports
    }

    private func openPort(_ id: Int) {
        let source = MIDIGetSource(id)
        guard source != 0 else {
            selectedPort = nil as Int?
            return
        }

        if midiConnectedSource != 0 {
            try! checkOSStatus(MIDIPortDisconnectSource(midiInputPort, midiConnectedSource))
        }

        print("opening source: midiInputPort=\(midiInputPort) source=\(source)")

        try! checkOSStatus(MIDIPortConnectSource(midiInputPort, source, nil))

        midiConnectedSource = source
    }

    private func checkOSStatus(_ result: OSStatus) throws {
        if result != 0 {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(result))
        }
    }

    public var receivedStruct = PassthroughSubject<AnyLivenStruct, Never>()
}
