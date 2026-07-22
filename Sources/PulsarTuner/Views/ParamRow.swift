import SwiftUI

struct ParamRow: View {
    let label: String
    let unit: String
    let range: ClosedRange<Double>
    let step: Double
    let originalValue: Int
    @Binding var value: Int

    private var isDirty: Bool { value != originalValue }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isDirty ? .orange : .primary)
                Spacer()
                if isDirty {
                    Text("was: \(originalValue)\(unit)")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }
            HStack {
                Slider(
                    value: Binding(
                        get: { Double(value) },
                        set: { value = Int($0) }
                    ),
                    in: range,
                    step: step
                )
                Text("\(value)\(unit)")
                    .font(.system(.body, design: .monospaced))
                    .frame(minWidth: 64, alignment: .trailing)
            }
        }
        .padding(.vertical, 6)
    }
}
