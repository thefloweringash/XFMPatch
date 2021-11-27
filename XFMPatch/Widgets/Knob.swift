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

    public static func mapRange<U: BinaryFloatingPoint, T: BinaryFloatingPoint>(from: ClosedRange<U>, to: ClosedRange<T>, point: U) -> T {
        let ratio = (to.upperBound - to.lowerBound) / T(from.upperBound - from.lowerBound)
        let fromOffset = T(point - from.lowerBound)
        return to.lowerBound + fromOffset * ratio
    }
}

struct KnobTrack: Shape {
    public var range: ClosedRange<CGFloat>
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

extension KnobTrack: Animatable {
    typealias AnimatableData = AnimatablePair<CGFloat, CGFloat>

    var animatableData: AnimatableData {
        get {
            return .init(range.lowerBound, range.upperBound)
        }
        set(newValue) {
            range = (newValue.first...newValue.second)
        }
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
    @Binding public var value: Float
    public let `in`: ClosedRange<Float>

    public var size: KnobSize = .Small
    public var resetValue: Float = 0

    @Environment(\.isEnabled) private var isEnabled: Bool

    @GestureState private var dragInitialValue: Float?

    var body: some View {
        let dragScale = (`in`.upperBound - `in`.lowerBound) / 100
        let dragLevel = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .updating($dragInitialValue) { (gestureValue, state, transaction) in
                state = state ?? value
            }
            .onChanged { gestureValue in
                value = clamp(dragInitialValue! + Float(-gestureValue.translation.height) * dragScale)
            }
        let reset = TapGesture(count: 2).onEnded {
            withAnimation(.easeInOut) {
                value = resetValue
            }
        }

        ZStack {
            KnobTrack(range: -1...1).stroke(isEnabled ? .blue : .gray)
            KnobTrack(range: {
                let mappedValue = KnobGeom.mapRange(from: `in`, to: -1...1, point: value)
                let basis = KnobGeom.mapRange(from: `in`, to: -1...1, point: 0)

                let lower = min(basis, mappedValue)
                let upper = max(basis, mappedValue)
                return lower...upper
            }()).fill(isEnabled ? .blue : .gray)
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        .gesture(dragLevel.exclusively(before: reset))
    }

    private func clamp(_ value: Float) -> Float {
        min(`in`.upperBound, max(`in`.lowerBound, value))
    }
}


struct IntKnob<U: BinaryInteger>: View {
    @Binding public var value: U
    public let `in`: ClosedRange<U>

    public var size: KnobSize = .Small
    public var resetValue: U = 0

    private var floatValue: Binding<Float> {
        Binding<Float>(
            get: { return Float(value) },
            set: { x in value = U(x) })
    }

    var body: some View {
        Knob(
            value: floatValue,
            in: Float(`in`.lowerBound)...Float(`in`.upperBound),
            size: size,
            resetValue: Float(resetValue)
        )
    }
}

struct KnobPreview: PreviewProvider {
    static var previews: some View {
        Group {
            Knob(value: .constant(0.1), in: -1.0...1.0)
            Knob(value: .constant(-0.1), in: -1.0...1.0)
            Knob(value: .constant(-16), in: -48...48)
            Knob(value: .constant(32), in: -48...48)
            Knob(value: .constant(63), in: 0...127)
            Knob(value: .constant(63), in: 0...127)
            IntKnob(value: .constant(63), in: 0...127)
        }
    }
}
