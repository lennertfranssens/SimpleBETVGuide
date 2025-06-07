import Foundation
import Combine
import CoreData

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [TVShowModel] = []

    @Published var selectedChannel: String? = nil
    @Published var selectedDate: Date? = nil
    @Published var availableChannels: [String] = []
    let dateOptions: [Date] = [
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        Date(),
        Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    ]

    private var context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext) {
        self.context = context

        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.search(for: text)
            }
            .store(in: &cancellables)

        loadAvailableChannels()
    }

    func loadAvailableChannels() {
        let request: NSFetchRequest<Channel> = Channel.fetchRequest()
        do {
            let channels = try context.fetch(request)
            availableChannels = channels.compactMap { $0.name }.sorted()
        } catch {
            print("Failed to load channels for filter.")
        }
    }

    func search(for text: String) {
        let showRequest: NSFetchRequest<TVShow> = TVShow.fetchRequest()

        var predicates: [NSPredicate] = []

        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "title CONTAINS[cd] %@", text),
                NSPredicate(format: "descriptionText != nil AND descriptionText CONTAINS[cd] %@", text)
            ]))
        }

        if let channel = selectedChannel, !channel.isEmpty {
            predicates.append(NSPredicate(format: "channel.name == %@", channel))
        }

        if let date = selectedDate {
            let start = Calendar.current.startOfDay(for: date)
            if let end = Calendar.current.date(byAdding: .day, value: 1, to: start) {
                predicates.append(NSPredicate(format: "startTime >= %@ AND startTime < %@", start as NSDate, end as NSDate))
            }
        }

        if !predicates.isEmpty {
            showRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        showRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TVShow.startTime, ascending: true)]

        do {
            let matches = try context.fetch(showRequest)
            results = matches.map { TVShowModel(from: $0) }
        } catch {
            print("Search error: \(error)")
        }
    }
}
