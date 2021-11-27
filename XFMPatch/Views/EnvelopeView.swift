import SwiftUI

struct GridBackground: View {
    var envelopeGeometry: EnvelopeGeometry

    var body: some View {
        KeyArea(envelopeGeometry: envelopeGeometry).fill(Color("EnvelopeKeyArea"))
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

extension KeyArea: Animatable {
    typealias AnimatableData = EnvelopeGeometry.AnimatableData
    var animatableData: AnimatableData {
        get {
            envelopeGeometry.animatableData
        }
        set {
            envelopeGeometry.animatableData = newValue
        }
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

extension EnvelopeShape: Animatable {
    typealias AnimatableData = EnvelopeGeometry.AnimatableData
    var animatableData: AnimatableData {
        get {
            envelopeGeometry.animatableData
        }
        set {
            envelopeGeometry.animatableData = newValue
        }
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

struct EnvelopeGeometry {
    struct Mapper {
        public let boundingRect: CGRect
        private let timeTotal: CGFloat
        private let levelMin: Int
        private let levelMax: Int

        init<T>(envelope: Envelope<T>, levelMin: Int, levelMax: Int, boundingRect: CGRect) where T: FixedWidthInteger {
            self.levelMin = levelMin
            self.levelMax = levelMax
            self.boundingRect = boundingRect

            self.timeTotal =
                Self.timescale(envelope.T1) +
                Self.timescale(envelope.T2) +
                Self.timescale(envelope.T3) +
                Self.timescale(envelope.T4)
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

        public func timeToX(_ times: [Int]) -> CGFloat {
            let result = times.map(Self.timescale).reduce(0, { $0 + $1 })
            return boundingRect.origin.x + boundingRect.size.width * CGFloat(result) / timeTotal
        }

        public func timeToX(_ times: Int...) -> CGFloat {
            let result = times.map(Self.timescale).reduce(0, { $0 + $1 })
            return boundingRect.origin.x + boundingRect.size.width * CGFloat(result) / timeTotal
        }

        private static func timescale(_ time: Int) -> CGFloat {
            return (CGFloat(time) + 10) / 100
        }
    }

    public let boundingRect: CGRect
    private let mapper: Mapper

    init<T>(envelope: Envelope<T>, levelMin: Int, levelMax: Int, boundingRect: CGRect) where T: FixedWidthInteger {
        self.boundingRect = boundingRect
        self.mapper = Mapper(envelope: envelope, levelMin: levelMin, levelMax: levelMax, boundingRect: boundingRect)

        start = CGPoint(x: boundingRect.origin.x, y: mapper.levelToY(0))

        let t = envelope.times
        let l = envelope.levels

        p1 = .init(
            x: mapper.timeToX(t.0),
            y: mapper.levelToY(l.0)
        )
        p2 = .init(
            x: mapper.timeToX(t.0, t.1),
            y: mapper.levelToY(l.1)
        )

        p3 = .init(
            x: mapper.timeToX(t.0, t.1, t.2),
            y: mapper.levelToY(l.2)
        )

        p4 = .init(
            x: mapper.timeToX(t.0, t.1, t.2, t.3),
            y: mapper.levelToY(l.3)
        )
    }

    public var start: CGPoint
    public var p1: CGPoint
    public var p2: CGPoint
    public var p3: CGPoint
    public var p4: CGPoint

    public func yToLevel(_ y: CGFloat) -> Int {
        return mapper.yToLevel(y)
    }

    public func levelToY(_ level: Int) -> CGFloat {
        return mapper.levelToY(level)
    }

    public func timeToX(_ times: Int...) -> CGFloat {
        return mapper.timeToX(times)
    }
}

extension EnvelopeGeometry: Animatable {
    var animatableData: EnvelopeAnimatableData {
        get {
            EnvelopeAnimatableData(points: (
                start.animatableData,
                p1.animatableData,
                p2.animatableData,
                p3.animatableData,
                p4.animatableData
            ))
        }
        set(newValue) {
            start.animatableData = newValue.points.0
            p1.animatableData = newValue.points.1
            p2.animatableData = newValue.points.2
            p3.animatableData = newValue.points.3
            p4.animatableData = newValue.points.4
        }
    }

    struct EnvelopeAnimatableData: VectorArithmetic {
        static func == (lhs: EnvelopeGeometry.EnvelopeAnimatableData, rhs: EnvelopeGeometry.EnvelopeAnimatableData) -> Bool {
            return lhs.points == rhs.points
        }

        public var points: (
            CGPoint.AnimatableData,
            CGPoint.AnimatableData,
            CGPoint.AnimatableData,
            CGPoint.AnimatableData,
            CGPoint.AnimatableData
        )

        mutating func scale(by rhs: Double) {
            points.0.scale(by: rhs)
            points.1.scale(by: rhs)
            points.2.scale(by: rhs)
            points.3.scale(by: rhs)
            points.4.scale(by: rhs)
        }

        var magnitudeSquared: Double {
            return points.0.magnitudeSquared + points.1.magnitudeSquared + points.2.magnitudeSquared + points.3.magnitudeSquared
        }

        static var zero: EnvelopeGeometry.EnvelopeAnimatableData = .init(
            points: (
                CGPoint.AnimatableData.zero,
                CGPoint.AnimatableData.zero,
                CGPoint.AnimatableData.zero,
                CGPoint.AnimatableData.zero,
                CGPoint.AnimatableData.zero
            )
        )

        static func + (lhs: EnvelopeGeometry.EnvelopeAnimatableData, rhs: EnvelopeGeometry.EnvelopeAnimatableData) -> EnvelopeGeometry.EnvelopeAnimatableData {
            EnvelopeAnimatableData(points: (
                lhs.points.0 + rhs.points.0,
                lhs.points.1 + rhs.points.1,
                lhs.points.2 + rhs.points.2,
                lhs.points.3 + rhs.points.3,
                lhs.points.4 + rhs.points.4
            ))
        }

        static func - (lhs: EnvelopeGeometry.EnvelopeAnimatableData, rhs: EnvelopeGeometry.EnvelopeAnimatableData) -> EnvelopeGeometry.EnvelopeAnimatableData {
            EnvelopeAnimatableData(points: (
                lhs.points.0 - rhs.points.0,
                lhs.points.1 - rhs.points.1,
                lhs.points.2 - rhs.points.2,
                lhs.points.3 - rhs.points.3,
                lhs.points.4 - rhs.points.4
            ))
        }
    }

    typealias AnimatableData = EnvelopeAnimatableData
}

// Level control only
struct Handle: View {
    @Binding public var level: Int
    public var offset: CGFloat
    public let geometry: EnvelopeGeometry

    var body: some View {
        let changeLevel = DragGesture(minimumDistance: 0)
            .onChanged { (state) in
                level = geometry.yToLevel(state.location.y)
            }
            .onEnded { (state) in
                level = geometry.yToLevel(state.location.y)
            }

        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 5, height: 5)
        }
        .frame(width: 32, height: 32)
        .contentShape(Circle())
        .position(.init(x: offset, y: geometry.levelToY(level)))
        .gesture(changeLevel)
    }
}

struct EnvelopeEditor<T>: View where T: FixedWidthInteger {
    @ObservedObject public var envelope: Envelope<T>

    public let levelMin: Int
    public let levelMax: Int

    var body: some View {
        VStack {
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
            }.frame(width: 300, height: 180)
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
