import SwiftUI

struct Box: Shape {
    public let rect: CGRect
    func path(in _: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        return path
    }
}

struct MatrixGeom {
    public let cellSize: CGFloat = 32
    public let cellGap: CGFloat = 2
    public let headerSize: CGFloat = 64

    public let rows: CGFloat = 5
    public let cols: CGFloat = 4

    public var size: CGSize {
        .init(width: cols * (cellGap + cellSize) + headerSize,
              height: rows * (cellGap + cellSize) + headerSize)
    }

    public func inputsFrame() -> CGRect {
        return CGRect.init(
            x: 0, y: 0,
            width: cols * cellSize + (cols - 1) * cellGap,
            height: headerSize
        )
    }

    func inputFrame(col: Int) -> CGRect {
        return CGRect.init(
            x: CGFloat(col) * (cellSize + cellGap),
            y: 0,
            width: cellSize,
            height: headerSize
        )
    }

    public func outputsFrame() -> CGRect {
        return CGRect.init(
            x: cols * (cellSize + cellGap),
            y: headerSize + cellGap,
            width: headerSize,
            height: rows * cellSize + (rows - 1) * cellGap
        )
    }

    func outputFrame(row: Int) -> CGRect {
        return CGRect.init(
            x: 0,
            y: CGFloat(row) * (cellSize + cellGap),
            width: headerSize,
            height: cellSize
        )
    }

    public func cellsFrame() -> CGRect {
        return CGRect.init(
            x: 0,
            y: headerSize + cellGap,
            width: cols * cellSize + (cols - 1) * cellGap,
            height: rows * cellSize + (rows - 1) * cellGap
        )
    }

    public func cellFrame(row: Int, col: Int) -> CGRect {
        return CGRect.init(
            x: CGFloat(col) * (cellSize + cellGap),
            y: headerSize + cellGap + CGFloat(row) * (cellSize + cellGap),
            width: cellSize,
            height: cellSize)
    }
}

struct MatrixFeedbackCell: View {
    @Binding public var level: Float
    public let mg: MatrixGeom
    public let row: Int
    public let col: Int

    var body: some View {
        let f = mg.cellFrame(row: row, col: col)
        ZStack {
            Rectangle().fill(.orange)
            Text(String(format: "%d", Int(level)))
        }
        .frame(width: f.size.width, height: f.size.height)
        .position(x: f.origin.x + f.size.width / 2,
                  y: f.origin.y + f.size.height / 2)
    }
}

struct MatrixReceiveCell: View {
    @Binding public var level: Float
    public let mg: MatrixGeom
    public let row: Int
    public let col: Int

    var body: some View {
        let f = mg.cellFrame(row: row, col: col)
        ZStack {
            Rectangle().fill(.pink)
            Text(String(format: "%d", Int(level)))
        }
        .frame(width: f.size.width, height: f.size.height)
        .position(x: f.origin.x + f.size.width / 2,
                  y: f.origin.y + f.size.height / 2)
    }
}

struct MatrixView: View {
    @ObservedObject public var matrix: Matrix

    var body: some View {
        let mg = MatrixGeom()

        ZStack {
            ZStack {
                Box(rect: mg.inputFrame(col: 0)).fill(Color.green)
                Box(rect: mg.inputFrame(col: 1)).fill(Color.green)
                Box(rect: mg.inputFrame(col: 2)).fill(Color.green)
                Box(rect: mg.inputFrame(col: 3)).fill(Color.green)
            }

            ZStack {
                Box(rect: mg.outputFrame(row: 0)).fill(Color.green)
                Box(rect: mg.outputFrame(row: 1)).fill(Color.green)
                Box(rect: mg.outputFrame(row: 2)).fill(Color.green)
                Box(rect: mg.outputFrame(row: 3)).fill(Color.green)
                Box(rect: mg.outputFrame(row: 4)).fill(Color.green)
            }.offset(x: mg.outputsFrame().origin.x,
                     y: mg.outputsFrame().origin.y)

            ZStack {
                Group {
                    MatrixFeedbackCell(level: $matrix.o1fb, mg: mg, row: 0, col: 0)
                    MatrixReceiveCell(level: $matrix.o1r2, mg: mg, row: 0, col: 1)
                    MatrixReceiveCell(level: $matrix.o1r3, mg: mg, row: 0, col: 2)
                    MatrixReceiveCell(level: $matrix.o1r4, mg: mg, row: 0, col: 3)
                }

                Group {
                    MatrixReceiveCell(level: $matrix.o2r1, mg: mg, row: 1, col: 0)
                    MatrixFeedbackCell(level: $matrix.o2fb, mg: mg, row: 1, col: 1)
                    MatrixReceiveCell(level: $matrix.o2r3, mg: mg, row: 1, col: 2)
                    MatrixReceiveCell(level: $matrix.o2r4, mg: mg, row: 1, col: 3)
                }

                Group {
                    MatrixReceiveCell(level: $matrix.o3r1, mg: mg, row: 2, col: 0)
                    MatrixReceiveCell(level: $matrix.o3r2, mg: mg, row: 2, col: 1)
                    MatrixFeedbackCell(level: $matrix.o3fb, mg: mg, row: 2, col: 2)
                    MatrixReceiveCell(level: $matrix.o3r4, mg: mg, row: 2, col: 3)
                }

                Group {
                    MatrixReceiveCell(level: $matrix.o4r1, mg: mg, row: 3, col: 0)
                    MatrixReceiveCell(level: $matrix.o4r2, mg: mg, row: 3, col: 1)
                    MatrixReceiveCell(level: $matrix.o4r3, mg: mg, row: 3, col: 2)
                    MatrixFeedbackCell(level: $matrix.o4fb, mg: mg, row: 3, col: 3)
                }

                Group {
                    MatrixReceiveCell(level: $matrix.mr1, mg: mg, row: 4, col: 0)
                    MatrixReceiveCell(level: $matrix.mr2, mg: mg, row: 4, col: 1)
                    MatrixReceiveCell(level: $matrix.mr3, mg: mg, row: 4, col: 2)
                    MatrixReceiveCell(level: $matrix.mr4, mg: mg, row: 4, col: 3)
                }
            }
        }.frame(width: mg.size.width, height: mg.size.height)
    }
}

struct MatrixView_Prviews: PreviewProvider {
    static var previews: some View {
        MatrixView(matrix: Matrix())
    }
}
