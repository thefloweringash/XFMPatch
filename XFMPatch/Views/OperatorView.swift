import SwiftUI

struct RatioEditor: View {
    @Binding public var value: Float

    private var intPart: Binding<Int> {
        Binding<Int>(
            get: { Int(modf(value).0) },
            set: { newValue in
                let old = modf(value)
                value = Float(newValue) + old.1
            }
        )
    }

    private var floatPart: Binding<Float> {
        Binding<Float>(
            get: { modf(value).1 },
            set: { newValue in
                let old = modf(value)
                value = old.0 + newValue
            }
        )
    }

    var body: some View {
        HStack {
            IntKnob(
                value: intPart,
                in: 0...32,
                resetValue: 1
            )
            Knob(
                value: floatPart,
                in: 0...0.99
            )
        }
    }
}

struct OperatorEditor: View {
    @ObservedObject var op: Operator

    var body: some View {
        VStack {
            HStack {
                Group {
                    Text("Level")
                    IntKnob(value: $op.level, in: 0...127, resetValue: 64)
                }
                Group {
                    Text("Velocity")
                    IntKnob(value: $op.velocity, in: 0...127)
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

                HStack {
                    Text("Ratio")
                    RatioEditor(value: $op.ratio)
                    SegmentedString(size: .Small, string: String(format: "%5.2f", op.ratio))
                }
                .disabled(op.mode != .Ratio)

                HStack {
                    Text("Frequency")
                    Knob(
                        value: $op.frequency,
                        in: 1...9831,
                        resetValue: 440
                    )
                    SegmentedString(size: .Small, string: String(format: "%4.0f", op.frequency))
                }
                .disabled(op.mode != .Fixed)

                HStack {
                    Text("Detune")
                    IntKnob(value: $op.detune, in: -63...63)
                }
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
