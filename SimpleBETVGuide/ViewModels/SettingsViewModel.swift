import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var lastUpdate: Date? = UserDefaults.standard.object(forKey: "lastUpdate") as? Date
    @Published var showAlert = false
    @Published var alertMessage = ""

    private let fetcher = XMLDataFetcher.shared

    func refreshData() {
        isLoading = true
        fetcher.fetchXMLAndParse { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success {
                    let now = Date()
                    self?.lastUpdate = now
                    UserDefaults.standard.set(now, forKey: "lastUpdate")
                } else {
                    self?.alertMessage = "Failed to update TV Guide. Please check your internet connection or try again later."
                    self?.showAlert = true
                }
            }
        }
    }
}
