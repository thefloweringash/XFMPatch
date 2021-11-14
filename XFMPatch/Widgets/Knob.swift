import SwiftUI

struct KnobGeom {
    public let frame: CGRect
    public let radius: CGFloat

    init(frame: CGRect, range: ClosedRange<CGFloat>) {
        self.frame = frame
        self.radius = 0.95 * min(frame.width, frame.height) / 2

        let myRange = 3/4 * CGFloat.pi ... (2 + 1/4) * CGFloat.pi
        self.startAngle = Self.mapRange(from: -1...1, to: myRange, point: range.lowerBound)
        self.endAngle = Self.mapRange(from: -1...1, to: myRange, point: range.upperBound)

        self.center = CGPoint(x: frame.origin.x + frame.size.width / 2,
                              y: frame.origin.y + frame.size.height / 2)
    }

    public let startAngle: CGFloat
    public let endAngle: CGFloat
    public let center: CGPoint

    lazy var gap = radius * 0.2

    lazy var lo: CGPoint = advance(angle: startAngle, distance: radius)
    lazy var li: CGPoint = advance(angle: startAngle, distance: radius - gap)

    lazy var ri: CGPoint = advance(angle: endAngle, distance: radius - gap)
    lazy var ro: CGPoint = advance(angle: endAngle, distance: radius)


    private func advance(angle: CGFloat, distance: CGFloat) -> CGPoint {
        let x: CGFloat = distance * cos(angle)
        let y: CGFloat = distance * sin(angle)
        return CGPoint(x: center.x + x,
                       y: center.y + y)
    }

    public static func mapRange<U: FloatingPoint>(from: ClosedRange<U>, to: ClosedRange<U>, point: U) -> U {
        let fromSize = from.upperBound - from.lowerBound
        let toSize = to.upperBound - to.lowerBound

        let fromOffset = point - from.lowerBound

        return to.lowerBound + fromOffset * (toSize / fromSize)
    }
}

struct KnobTrack: Shape {
    public let range: ClosedRange<CGFloat>
    func path(in rect: CGRect) -> Path {
        var g = KnobGeom(frame: rect, range: range)
        var path = Path()

        path.move(to: g.lo)
        path.addArc(center: g.center, radius: g.radius,
                    startAngle: .radians(g.startAngle),
                    endAngle: .radians(g.endAngle),
                    clockwise: false)
        path.addLine(to: g.ri)
        path.addArc(center: g.center, radius: g.radius - g.gap,
                    startAngle: .radians(g.endAngle),
                    endAngle: .radians(g.startAngle),
                    clockwise: true)
        path.addLine(to: g.lo)


        return path
    }
}

enum KnobSize {
    case Small

    var height: CGFloat {
        return 32
    }

    var width: CGFloat {
        return 32
    }
}

struct Knob: View {
    public let range: ClosedRange<CGFloat>
    public let size: KnobSize

    @Binding public var value: CGFloat
    @GestureState public var valuePreview: CGFloat?

    var body: some View {
        let dragScale = (range.upperBound - range.lowerBound) / 100
        let dragLevel = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .updating($valuePreview) { (gestureValue, state, transaction) in
                state = clamp(value + CGFloat(-gestureValue.translation.height) * dragScale)
            }
            .onEnded { gestureValue in
                value = clamp(value + CGFloat(-gestureValue.translation.height) * dragScale)
            }

        ZStack {
            KnobTrack(range: -1...1).stroke(.blue)
            KnobTrack(range: {
                let mappedValue = KnobGeom.mapRange(from: range, to: -1...1, point: valuePreview ?? value)
                let basis = KnobGeom.mapRange(from: range, to: -1...1, point: 0)

                let lower = min(basis, mappedValue)
                let upper = max(basis, mappedValue)
                return lower...upper
            }()).fill(.blue)
        }
        .frame(width: size.width, height: size.height)
        .background()
        .gesture(dragLevel)
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        min(range.upperBound, max(range.lowerBound, value))
    }
}

struct IntKnob<U: BinaryInteger>: View {
    public let range: ClosedRange<U>
    public let size: KnobSize

    @Binding public var value: U

    private var floatValue: Binding<CGFloat> {
        Binding<CGFloat>(
            get: { return CGFloat(value) },
            set: { x in value = U(x) })
    }

    var body: some View {
        Knob(
            range: CGFloat(range.lowerBound)...CGFloat(range.upperBound),
            size: size,
            value: floatValue
        )
    }
}

struct KnobPreview: PreviewProvider {
    static var previews: some View {
        Group {
            Knob(range: -1.0...1.0, size: .Small, value: .constant(0.1))
            Knob(range: -1.0...1.0, size: .Small, value: .constant(-0.1))
            Knob(range: -48...48, size: .Small, value: .constant(-16))
            Knob(range: -48...48, size: .Small, value: .constant(32))
            Knob(range: 0...127, size: .Small, value: .constant(63))
            IntKnob(range: 0...127, size: .Small, value: .constant(63))
        }
    }
}
