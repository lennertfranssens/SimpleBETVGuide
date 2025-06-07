//
//  TVGuideViewModel.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//


import Foundation
import CoreData
import Combine

class TVGuideViewModel: ObservableObject {
    @Published var showsByDay: [Date: [TVShowModel]] = [:]
    @Published var selectedDay: Date = Calendar.current.startOfDay(for: Date())
    @Published var favoriteChannels: Set<UUID> = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadFavorites()
        loadTVShows()
    }

    func loadTVShows() {
        let request: NSFetchRequest<TVShow> = TVShow.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TVShow.startTime, ascending: true)]

        do {
            let results = try context.fetch(request)
            let models = results.map { TVShowModel(from: $0) }

            // Filter to favorites
            let filtered = favoriteChannels.isEmpty ? models : models.filter { favoriteChannels.contains($0.channelID) }

            // Group by start date
            let grouped = Dictionary(grouping: filtered) { $0.startDateOnly }

            DispatchQueue.main.async {
                self.showsByDay = grouped
            }
        } catch {
            print("Failed to fetch TV shows: \(error)")
        }
    }

    func loadFavorites() {
        let request: NSFetchRequest<Channel> = Channel.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")

        if let results = try? context.fetch(request) {
            favoriteChannels = Set(results.compactMap { $0.id })
        }
    }

    var sortedDays: [Date] {
        showsByDay.keys.sorted()
    }

    func shows(for date: Date) -> [TVShowModel] {
        showsByDay[date] ?? []
    }
}