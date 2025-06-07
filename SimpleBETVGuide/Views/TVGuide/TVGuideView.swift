import SwiftUI

struct TVGuideView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: TVGuideViewModel
    @State private var isLoading: Bool = false

    init() {
        _viewModel = StateObject(wrappedValue: TVGuideViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Picker("Day", selection: $viewModel.selectedDay) {
                        ForEach(viewModel.sortedDays, id: \.self) { day in
                            Text(Self.dateLabel(for: day)).tag(day)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    TVGuideContentView(shows: viewModel.shows(for: viewModel.selectedDay))
                }
                .disabled(isLoading) // disable interaction while loading
                .blur(radius: isLoading ? 3 : 0)

                if isLoading {
                    VStack {
                        ProgressView("Updating TV Guide...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                            .shadow(radius: 5)
                    }
                    .transition(.opacity)
                }
            }
            .navigationTitle("TV Guide")
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        isLoading = true
        UpdateManager.shared.checkAndUpdateIfNeeded(context: context) { updated in
            viewModel.loadFavorites()
            viewModel.loadTVShows()
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }

    static func dateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d" // Example: "Fri, Jun 7"
        return formatter.string(from: date)
    }

}
