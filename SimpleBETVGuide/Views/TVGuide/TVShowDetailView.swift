import SwiftUI

struct TVShowDetailView: View {
    let show: TVShowModel
    @Environment(\.dismiss) var dismiss
    @State private var subscribedToEpisode: Bool
    @State private var subscribedToSeries: Bool

    init(show: TVShowModel) {
        self.show = show
        _subscribedToEpisode = State(initialValue: show.isSubscribedToEpisode)
        _subscribedToSeries = State(initialValue: show.isSubscribedToSeries)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Program Info")) {
                    Text(show.title).bold()
                    Text("Channel: \(show.channelName)")
                    Text("Time: \(timeRange)")
                    if let ep = show.episode {
                        Text("Episode: \(ep)")
                    }
                    Text(show.descriptionText)
                        .padding(.top, 4)
                }

                Section(header: Text("Reminders")) {
                    Toggle("Notify for this episode", isOn: $subscribedToEpisode)
                        .onChange(of: subscribedToEpisode) { newValue in
                            SubscriptionStore.shared.toggleSubscription(for: show, matchTitle: false)
                        }

                    Toggle("Notify for all episodes", isOn: $subscribedToSeries)
                        .onChange(of: subscribedToSeries) { newValue in
                            SubscriptionStore.shared.toggleSubscription(for: show, matchTitle: true)
                        }
                }
            }
            .navigationTitle("Details")
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }

    var timeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: show.startTime)) - \(formatter.string(from: show.endTime))"
    }
}
