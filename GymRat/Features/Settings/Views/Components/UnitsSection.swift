import SwiftUI

struct UnitsSection: View {
    @Binding private var weightUnit: String
    @Binding private var distanceUnit: String

    init(
        weightUnit: Binding<String>,
        distanceUnit: Binding<String>
    ) {
        self._weightUnit = weightUnit
        self._distanceUnit = distanceUnit
    }

    // MARK: - Body
    var body: some View {
        Section("units_section") {
            Picker("weight_unit_label", selection: $weightUnit) {
                ForEach(WeightUnit.allCases, id: \.rawValue) { unit in
                    Text(unit.label).tag(unit.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Picker("distance_unit_label", selection: $distanceUnit) {
                ForEach(DistanceUnit.allCases, id: \.rawValue) { unit in
                    Text(unit.label).tag(unit.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
