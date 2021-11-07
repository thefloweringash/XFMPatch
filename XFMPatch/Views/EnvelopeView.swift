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

struct ZeroLine: Shape {
    var envelopeGeometry: EnvelopeGeometry

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let bounds = envelopeGeometry.boundingRect
        let y: CGFloat = envelopeGeometry.levelToY(0)

        path.move(to: .init(x: bounds.origin.x,
                            y: y))
        path.addLine(to: .init(x: bounds.origin.x + bounds.size.width,
                               y: y))

        return path;
    }
}

class EnvelopeGeometry {
    public let boundingRect: CGRect
    private let timeTotal: CGFloat
    private let levelMin: Int
    private let levelMax: Int

    // TODO: type erased envelope params
    private let l: (Int, Int, Int, Int)
    private let t: (Int, Int, Int, Int)

    init<T>(envelope: Envelope<T>, levelMin: Int, levelMax: Int, boundingRect: CGRect) where T: FixedWidthInteger {
        self.levelMin = levelMin
        self.levelMax = levelMax

        self.boundingRect = boundingRect

        self.l = envelope.levels
        self.t = envelope.times

        self.timeTotal =
        EnvelopeGeometry.timescale(t.0) +
        EnvelopeGeometry.timescale(t.1) +
        EnvelopeGeometry.timescale(t.2) +
        EnvelopeGeometry.timescale(t.3);
    }

    public var start: CGPoint {
        .init(
            x: boundingRect.origin.x,
            y: levelToY(l.3)
        )
    }

    public var p1: CGPoint {
        .init(
            x: timeToX(t.0),
            y: levelToY(l.0)
        )
    }

    public var p2: CGPoint {
        .init(
            x: timeToX(t.0, t.1),
            y: levelToY(l.1)
        )
    }

    public var p3: CGPoint {
        .init(
            x: timeToX(t.0, t.1, t.2),
            y: levelToY(l.2)
        )
    }

    public var p4: CGPoint {
        .init(
            x: timeToX(t.0, t.1, t.2, t.3),
            y: levelToY(l.3)
        )
    }

    public func yToLevel(_ y: CGFloat) -> Int {
        let scale = CGFloat(levelMax - levelMin) / boundingRect.size.height
        let raw = levelMax - Int((y - boundingRect.origin.y) * scale)
        return min(levelMax, max(levelMin, Int(raw)))
    }

    public func levelToY(_ level: Int) -> CGFloat {
        let scale = boundingRect.size.height / CGFloat(levelMax - levelMin)
        return CGFloat(levelMax - level) * scale + boundingRect.origin.y
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

struct EnvelopeEditor<T>: View where T: FixedWidthInteger {
    @ObservedObject public var envelope: Envelope<T>

    public let levelMin: Int
    public let levelMax: Int

    var body: some View {
        HStack {
            GeometryReader { (viewGeom) in
                let envRect = viewGeom.frame(in: .local).insetBy(dx: 28, dy: 28)
                let geometry = EnvelopeGeometry(envelope: envelope,
                                                levelMin: levelMin,
                                                levelMax: levelMax,
                                                boundingRect: envRect)

                ZStack() {
                    GridBackground(envelopeGeometry: geometry)

                    if levelMin != 0 {
                        ZeroLine(envelopeGeometry: geometry).stroke(.green)
                    }

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
        EnvelopeEditor(
            envelope: AmpEnvelope(),
            levelMin: -48,
            levelMax: 48
        )
    }
}
