import SwiftUI

struct Segs: Shape {
    public let segments: UInt32
    
    static let inset: CGFloat = 0.12
    static let gap: CGFloat = 0.028
    static let dotSize: CGFloat = 0.02
    static let segSize: CGFloat = 0.03
    
    struct Segment {
        public let from: KeyPath<Points, CGPoint>
        public let to: KeyPath<Points, CGPoint>
    }
    
    struct Points {
        let tl, tc, tr: CGPoint
        let cl, cc, cr: CGPoint
        let bl, bc, br: CGPoint
        
        init(in rect: CGRect) {
            let inset = rect.size.width * Segs.inset
            
            let left = rect.origin.x + inset
            let hCenter = rect.origin.x + rect.size.width / 2
            let right = rect.origin.x + rect.size.width - inset
            
            let top = rect.origin.y + inset
            let vCenter = rect.origin.y + rect.size.height / 2
            let bottom = rect.origin.y + rect.size.height - inset
            
            tl = .init(x: left, y: top)
            tc = .init(x: hCenter, y: top)
            tr = .init(x: right, y: top)
            
            cl = .init(x: left, y: vCenter)
            cc = .init(x: hCenter, y: vCenter)
            cr = .init(x: right, y: vCenter)
            
            bl = .init(x: left, y: bottom)
            bc = .init(x: hCenter, y: bottom)
            br = .init(x: right, y: bottom)
        }
    }
    
    struct Drawer {
        public private(set) var path = Path()
        public let points: Points
        public let gap: CGFloat
        public let segSize: CGFloat
        
        mutating public func dot(size: CGFloat, _ ps: CGPoint...) {
            for p in ps {
                path.move(to: .init(x: p.x + size, y: p.y))
                path.addArc(center: p,
                            radius: size,
                            startAngle: .zero, endAngle: .degrees(180), clockwise: true)
                path.addArc(center: p,
                            radius: size,
                            startAngle: .degrees(180), endAngle: .degrees(360), clockwise: true)
            }
        }
        
        mutating public func segment(from: CGPoint, to: CGPoint) {
            // draw a line of the correct distance
            let dx = to.x - from.x
            let dy = to.y - from.y
            let distance = sqrt(dx * dx + dy * dy) - 2 * gap
            
            var segPath = Path()
            
            segPath.addLines([
                .init(x: 0, y: 0),
                .init(x: segSize, y: segSize),
                .init(x: distance - segSize, y: segSize),
                .init(x: distance, y: 0),
                .init(x: distance - segSize, y: -segSize),
                .init(x: segSize, y: -segSize),
                .init(x: 0, y: 0)
            ])
            
            let angle: CGFloat
            if dx == 0 {
                angle = dy > 0 ? Double.pi / 2 : -(Double.pi / 2)
            } else {
                angle = atan(dy / dx)
            }
            
            let transform: CGAffineTransform =
                .init(translationX: from.x, y: from.y)
                .rotated(by: angle)
                .translatedBy(x: gap, y: 0)
            path.addPath(segPath, transform: transform)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let points = Points(in: rect)
        
        var d = Drawer(
            points: points,
            gap: Segs.gap * rect.height,
            segSize: Segs.segSize * rect.height
        )
        
//        d.dot(size: Segs.gap * rect.height,
//              points.tl, points.tc, points.tr,
//              points.cl, points.cc, points.cr,
//              points.bl, points.bc, points.br
//        )
        
        for s in gatherSegments(segments) {
            d.segment(from: points[keyPath: s.from], to: points[keyPath: s.to])
        }
        if segments & (1 << 17) != 0 {
            let r = Segs.gap * rect.height
            d.dot(size: Segs.gap * rect.height,
                  CGPoint(x: points.br.x + r * 4,
                          y: points.br.y - r * 2))
        }
        
        
        var path = Path()
        let c = 0.1
        let tx = rect.height * c / 2
        path.addPath(d.path, transform: .init(a: 1, b: 0.0,
                                              c: -0.1, d: 1,
                                              tx: tx, ty: 0))
        return path
    }
    
    private func gatherSegments(_ segs: UInt32) -> [Segment] {
        return [
            Segment(from: \.tl, to: \.tc),
            Segment(from: \.tc, to: \.tr),
            Segment(from: \.tl, to: \.cl),
            Segment(from: \.tl, to: \.cc),
            Segment(from: \.tc, to: \.cc),
            Segment(from: \.cc, to: \.tr),
            Segment(from: \.tr, to: \.cr),
            Segment(from: \.cl, to: \.cc),
            Segment(from: \.cc, to: \.cr),
            Segment(from: \.cl, to: \.bl),
            Segment(from: \.bl, to: \.cc),
            Segment(from: \.cc, to: \.bc),
            Segment(from: \.cc, to: \.br),
            Segment(from: \.cr, to: \.br),
            Segment(from: \.bl, to: \.bc),
            Segment(from: \.bc, to: \.br),
        ].enumerated().filter { i, s in
            (1 << i) & segs != 0
        }.map { $1 }
    }
}

struct SegmentedString: View {
    @Environment(\.isEnabled) private var isEnabled: Bool

    struct SegCharacter: Identifiable {
        typealias ID = Int
        
        public let id: Int
        public var segments: UInt32
    }
    
    enum Size {
        case Tiny
        case Small
        case Huge
        
        var width: CGFloat {
            switch self {
                case .Tiny: return 8
                case .Small: return 16
                case .Huge: return 160
            }
        }
        
        var height: CGFloat {
            width * 1.5
        }

        var shadowRadius: CGFloat {
            switch self {
                case .Tiny: return 1
                case .Small: return 2
                case .Huge: return 18
            }
        }
    }
    
    public let size: Size
    public let string: String
    
    var body: some View {
        HStack {
            ForEach(toCharacters(string)) { c in
                ZStack {
                    let segs = Segs(segments: c.segments)
                    segs.shadow(color: isEnabled ? .blue : .gray, radius: size.shadowRadius, x: 0, y: 0)
                    segs.fill(isEnabled ? .blue : .gray)
                }.frame(width: size.width, height: size.height)
            }
        }
    }
    
    private func toCharacters(_ string: String) -> [SegCharacter] {
        var result: [SegCharacter] = []

        for (i, c) in string.enumerated() {
            if c == "." && !result.isEmpty && result.last!.segments & (1 << 17) == 0 {
                result[result.count - 1].segments |= 1 << 17
            } else {
                result.append(SegCharacter(id: i, segments: sevenSegmentFont[c] ?? UInt32.max))
            }
        }

        return result
    }
}

class HugeSegsPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            SegmentedString(size: .Huge, string: "ABCDEFG")
            SegmentedString(size: .Huge, string: "HIJKLMN")
            SegmentedString(size: .Huge, string: "OPQRSTU")
            SegmentedString(size: .Huge, string: "VWXYZ  ")
            SegmentedString(size: .Huge, string: "1234567")
            SegmentedString(size: .Huge, string: "890   a")
        }
    }
}

class SmallSegsPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            SegmentedString(size: .Small, string: "ABCDEFG")
            SegmentedString(size: .Small, string: "HIJKLMN")
            SegmentedString(size: .Small, string: "OPQRSTU")
            SegmentedString(size: .Small, string: "VWXYZ  ")
            SegmentedString(size: .Small, string: "1234567")
            SegmentedString(size: .Small, string: "890   a")
            SegmentedString(size: .Small, string: "1.2..3.4")
        }
    }
}
