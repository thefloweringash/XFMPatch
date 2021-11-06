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
                    Text("32.00")
                }
                .disabled(op.mode != .Ratio)

                Slider(
                    value: $op.frequency,
                    in: 1...9831
                ) {
                    Text("Frequency")
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("9831")
                }
                .disabled(op.mode != .Fixed)
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
