import SwiftUI
import Foundation

struct SearchView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: SearchViewModel
    @State private var selectedShow: TVShowModel?

    init() {
        _viewModel = StateObject(wrappedValue: SearchViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search Input
                TextField("Search TV shows...", text: $viewModel.query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // Channel + Date Filters
                FilterBar(viewModel: viewModel)

                // Results List
                List(viewModel.results, id: \.id) { show in
                    VStack(alignment: .leading) {
                        highlightText(show.title, with: viewModel.query)
                            .font(.headline)
                        Text("\(show.channelName) — \(formattedTime(show))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        highlightText(show.descriptionText, with: viewModel.query)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedShow = show
                    }
                }
            }
            .navigationTitle("Search")
            .sheet(item: $selectedShow) { show in
                TVShowDetailView(show: show)
            }
        }
    }

    // MARK: - Helpers

    private func formattedTime(_ show: TVShowModel) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE HH:mm"
        return formatter.string(from: show.startTime)
    }

    private func highlightText(_ text: String, with query: String) -> Text {
        guard !query.isEmpty else {
            return Text(text)
        }

        let parts = text.components(separatedBy: query)
        var result = Text("")

        for i in 0..<parts.count {
            result = result + Text(parts[i])
            if i < parts.count - 1 {
                result = result + Text(query).bold().foregroundColor(.accentColor)
            }
        }
        return result
    }
}
