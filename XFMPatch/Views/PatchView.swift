import SwiftUI

struct PatchView: View {
    @ObservedObject public var patch: Patch

    var body: some View {
        VStack {
            SegmentedString(size: .Small, string: patch.name)

            HStack(alignment: .top) {
                SectionView("Operator 1") { OperatorEditor(op: patch.operators.0) }
                SectionView("Operator 2") { OperatorEditor(op: patch.operators.1) }
                SectionView("Operator 3") { OperatorEditor(op: patch.operators.2) }
                SectionView("Operator 4") { OperatorEditor(op: patch.operators.3) }
                VStack(alignment: .leading) {
                    SectionView("Matrix") {
                        MatrixView(matrix: patch.matrix)
                    }
                    SectionView("Pitch Envelope") {
                        PitchEGView(eg: patch.pitchEnvelope)
                    }
                }
            }
        }
    }
}
