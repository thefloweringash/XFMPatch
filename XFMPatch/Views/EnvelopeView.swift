import SwiftUI

struct GridBackground: View {
    var envelopeGeometry: EnvelopeGeometry

    var body: some View {
        Rectangle()
            .stroke()

        KeyArea(envelopeGeometry: envelopeGeometry).fill(.ultraThinMaterial)
    }
}

struct KeyArea: Shape {
    var envelopeGeometry: EnvelopeGeometry

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addRect(.init(
            x: envelopeGeometry.start.x,
            y: envelopeGeometry.boundingRect.origin.y,
            width: envelopeGeometry.p3.x - envelopeGeometry.start.x,
            height: envelopeGeometry.boundingRect.height
        ))

        return path;
    }
}

struct EnvelopeShape: Shape {
    var envelopeGeometry: EnvelopeGeometry

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: envelopeGeometry.start)
        path.addLine(to: envelopeGeometry.p1)
        path.addLine(to: envelopeGeometry.p2)
        path.addLine(to: envelopeGeometry.p3)
        path.addLine(to: envelopeGeometry.p4)

        return path;
    }
}

class EnvelopeGeometry {
    public let envelope: AmpEnvelope
    public let boundingRect: CGRect
    private let timeTotal: CGFloat

    init(envelope: AmpEnvelope, boundingRect: CGRect) {
        self.envelope = envelope
        self.boundingRect = boundingRect
        self.timeTotal =
        EnvelopeGeometry.timescale(envelope.T1) +
        EnvelopeGeometry.timescale(envelope.T2) +
        EnvelopeGeometry.timescale(envelope.T3) +
        EnvelopeGeometry.timescale(envelope.T4);
    }

    public var start: CGPoint {
        .init(
            x: boundingRect.origin.x,
            y: levelToY(envelope.L4)
        )
    }

    public var p1: CGPoint {
        .init(
            x: timeToX(envelope.T1),
            y: levelToY(envelope.L1)
        )
    }

    public var p2: CGPoint {
        .init(
            x: timeToX(envelope.T1, envelope.T2),
            y: levelToY(envelope.L2)
        )
    }

    public var p3: CGPoint {
        .init(
            x: timeToX(envelope.T1, envelope.T2, envelope.T3),
            y: levelToY(envelope.L3)
        )
    }

    public var p4: CGPoint {
        .init(
            x: timeToX(envelope.T1, envelope.T2, envelope.T3, envelope.T4),
            y: levelToY(envelope.L4)
        )
    }

    public func yToLevel(_ y: CGFloat) -> Int {
        let raw = Int((1 - ((y -  boundingRect.origin.y) / boundingRect.height)) * 127)
        return min(127, max(raw, 0))
    }

    public func levelToY(_ level: Int) -> CGFloat {
        boundingRect.origin.y + boundingRect.height * (1 - (CGFloat(level) / 127))
    }

    public func timeToX(_ times: Int...) -> CGFloat {
        let result = times.map(EnvelopeGeometry.timescale).reduce(0, { $0 + $1 })
        return boundingRect.origin.x + boundingRect.size.width * CGFloat(result) / timeTotal
    }

    private static func timescale(_ time: Int) -> CGFloat {
        return (CGFloat(time) + 10) / 100
    }
}

// Level control only
struct Handle: View {
    @Binding public var level: Int
    public var offset: CGFloat
    public let geometry: EnvelopeGeometry

    var body: some View {
        let changeLevel = DragGesture()
            .onChanged { (state) in
                level = geometry.yToLevel(state.location.y)
            }
            .onEnded { (state) in
                level = geometry.yToLevel(state.location.y)
            }

        ZStack {
            Circle()
                .fill(Color.red)
                .frame(width: 32, height: 32)
                .position(.init(x: offset, y: geometry.levelToY(level)))
                .gesture(changeLevel)

            Circle()
                .fill(Color.blue)
                .frame(width: 5, height: 5)
                .position(.init(x: offset, y: geometry.levelToY(level)))
        }

    }
}

struct EnvelopeEditor: View {
    @ObservedObject public var envelope: AmpEnvelope

    var body: some View {
        HStack {
            GeometryReader { (viewGeom) in
                let envRect = viewGeom.frame(in: .local).insetBy(dx: 28, dy: 28)
                let geometry = EnvelopeGeometry(envelope: envelope, boundingRect: envRect)

                ZStack() {
                    GridBackground(envelopeGeometry: geometry)

                    EnvelopeShape(envelopeGeometry: geometry).stroke(.blue)

                    Handle(level: $envelope.L1, offset: geometry.p1.x, geometry: geometry)
                    Handle(level: $envelope.L2, offset: geometry.p2.x, geometry: geometry)
                    Handle(level: $envelope.L3, offset: geometry.p3.x, geometry: geometry)
                    Handle(level: $envelope.L4, offset: geometry.p4.x, geometry: geometry)
                }
            }.frame(width: 400, height: 300)
        }
    }
}


struct EnvelopeEditor_Previews: PreviewProvider {
    static var previews: some View {
        EnvelopeEditor(envelope: Envelope())
    }
}
