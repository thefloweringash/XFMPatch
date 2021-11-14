import SwiftUI

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
                    HStack {
                        Text("L-Gain")
                        IntKnob(range: -63...63, size: .Small, value: $scale.lGain)
                    }
                    CurvePicker(label: "L-Curve", value: $scale.lCurve)
                }
                VStack {
                    HStack {
                        Text("R-Gain")
                        IntKnob(range: -63...63, size: .Small, value: $scale.rGain)
                    }
                    CurvePicker(label: "R-Curve", value: $scale.rCurve)
                }
            }
            Picker("Scale Pos", selection: $scale.scalePos) {
                ForEach(Scale.ScalePos.allCases) { pos in
                    Text(pos.description).tag(pos)
                }
            }.pickerStyle(.segmented)

        }
    }

}

struct ScaleView_Preview: PreviewProvider {
    static var previews: some View {
        ScaleView(scale: Scale())
    }
}
