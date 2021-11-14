import SwiftUI

struct OperatorEditor: View {
    @ObservedObject var op: Operator

    var body: some View {
        VStack {
            HStack {
                Group {
                    Text("Level")
                    IntKnob(range: 0...127, size: .Small, value: $op.level)
                }
                Group {
                    Text("Velocity")
                    IntKnob(range: 0...127, size: .Small, value: $op.velocity)
                }
            }

            Divider()

            Group {
                Text("Envelope").font(.subheadline)
                OperatorEnvelopeEditor(openv: op.envelope)
            }

            Divider()

            Group {
                Text("Ratio and Frequency").font(.subheadline)

                Picker("Mode", selection: $op.mode) {
                    ForEach(Operator.OperatorMode.allCases) { mode in
                        Text(mode.description).tag(mode)
                    }
                }.pickerStyle(.segmented)

                Slider(value: $op.ratio, in: 0.5...32.0) {
                    Text("Ratio")
                } minimumValueLabel: {
                    Text("0.5")
                } maximumValueLabel: {
                    Text("32.00")
                }
                .disabled(op.mode != .Ratio)

                HStack {
                    Text("Detune")
                    IntKnob(range: -63...63, size: .Small, value: $op.detune)
                }

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

            Divider()

            Group {
                Text("Key Scale").font(.subheadline)
                ScaleView(scale: op.scale)
            }
        }.fixedSize()
    }
}

struct OperatorEditor_Previews: PreviewProvider {
    static var previews: some View {
        OperatorEditor(op: Operator())
    }
}
