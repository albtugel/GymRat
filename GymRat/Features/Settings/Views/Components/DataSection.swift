import SwiftUI

struct DataSection: View {
    private let onReset: () -> Void

    init(onReset: @escaping () -> Void) {
        self.onReset = onReset
    }


    var body: some View {
        Section("data_section") {
            Button(role: .destructive) {
                onReset()
            } label: {
                Text("reset_all_data_button")
            }
        }
    }
}
