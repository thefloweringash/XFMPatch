import SwiftUI

struct PatchView: View {
    @ObservedObject public var patch: Patch

    var body: some View {
        VStack {
            Text(patch.name)
            
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
        }
    }
}
