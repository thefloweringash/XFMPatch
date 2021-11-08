import SwiftUI

struct PatchView: View {
    @ObservedObject public var patch: Patch

    var body: some View {
        VStack {
            SegmentedString(size: .Small, string: patch.name)

            HStack {
                VStack {
                    HStack {
                        OperatorEditor(op: patch.operators.0)
                        OperatorEditor(op: patch.operators.1)
                    }
                    HStack {
                        OperatorEditor(op: patch.operators.2)
                        OperatorEditor(op: patch.operators.3)
                    }
                }
                VStack {
                    MatrixView(matrix: patch.matrix)
                    PitchEGView(eg: patch.pitchEnvelope)
                }
            }
        }
    }
}
