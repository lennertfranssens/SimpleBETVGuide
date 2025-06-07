import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data")) {
                    HStack {
                        Text("Last updated")
                        Spacer()
                        if let lastUpdate = viewModel.lastUpdate {
                            Text(Self.format(date: lastUpdate))
                                .foregroundColor(.secondary)
                        } else {
                            Text("Never")
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: {
                        viewModel.refreshData()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                            }
                            Text("Force Refresh")
                        }
                    }
                    .disabled(viewModel.isLoading)
                }

                // Optional section for other app settings
                Section(header: Text("Preferences")) {
                    Toggle("Auto Refresh on Launch", isOn: .constant(true)) // Make dynamic if desired
                        .disabled(true) // Just a placeholder for now
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Update Failed"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
