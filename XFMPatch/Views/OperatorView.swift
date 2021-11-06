import SwiftUI

struct OperatorEditor: View {
    @ObservedObject public var op: Operator

    var body: some View {
        VStack {
            EnvelopeEditor(envelope: op.envelope)

            VStack {
                Slider(
                    value: $op.level,
                    in: 0...127
                ) {
                    Text("Level")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("127")
                }

                Picker("Mode", selection: $op.mode) {
                    ForEach(Operator.OperatorMode.allCases) { mode in
                        Text(mode.description).tag(mode)
                    }
                }.pickerStyle(.segmented)

                Slider(
                    value: $op.ratio,
                    in: 0.5...32.0
                ) {
                    Text("Ratio")
                } minimumValueLabel: {
                    Text("0.5")
                } maximumValueLabel: {
                    Text("9755")
                }
                .disabled(op.mode != .Ratio)

                Slider(
                    value: $op.frequency, in: 1...9755, label: { Text("Frequency") }
                ).disabled(op.mode != .Fixed)
            }

            ScaleView(scale: op.scale)
        }.fixedSize()
    }
}

struct OperatorEditor_Previews: PreviewProvider {
    static var previews: some View {
        OperatorEditor(op: Operator())
    }
}
