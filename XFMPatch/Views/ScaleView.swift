import SwiftUI

struct GainSlider: View {
    var label: String
    @Binding var value: Float

    var body: some View {
        Slider(
            value: $value,
            in: -63.0...63.0,
            step: 1.0,
            label: { Text(label) }
        )
    }
}

struct CurvePicker: View {
    var label: String
    @Binding var value: Scale.CurveType

    var body: some View {
        Picker(label, selection: $value) {
            Text("LINE").tag(Scale.CurveType.Linear)
            Text("EXP").tag(Scale.CurveType.Exponential)
        }
        .pickerStyle(.segmented)
    }
}

struct ScaleView: View {
    @ObservedObject public var scale: Scale

    var body: some View {
        VStack {
            HStack {
                VStack {
                    GainSlider(label: "L-Gain", value: $scale.lGain)
                    CurvePicker(label: "L-Curve", value: $scale.lCurve)
                }
                VStack {
                    GainSlider(label: "R-Gain", value: $scale.rGain)
                    CurvePicker(label: "R-Curve", value: $scale.rCurve)
                }
            }
            Picker("Scale Pos", selection: $scale.scalePos) {
                ForEach(Scale.ScalePos.allCases) { pos in
                    Text(pos.description).tag(pos)
                }
            }.pickerStyle(.segmented)

        }
        .fixedSize() // TODO: critical for performance

    }

}

struct ScaleView_Preview: PreviewProvider {
    static var previews: some View {
        ScaleView(scale: Scale())
    }
}
