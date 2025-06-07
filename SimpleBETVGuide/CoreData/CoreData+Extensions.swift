//
//  CoreData+Extensions.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//

import Foundation
import CoreData

extension Channel {
    static func fetchRequestSorted() -> NSFetchRequest<Channel> {
        let request = Channel.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request 
    }

    var wrappedName: String {
        name ?? "Unknown Channel"
    }

    var showsArray: [TVShow] {
        let set = tvShows as? Set<TVShow> ?? []
        return set.sorted { $0.startTime ?? Date.distantPast < $1.startTime ?? Date.distantPast }
    }
}

extension TVShow {
    static func fetchRequestForDay(date: Date) -> NSFetchRequest<TVShow> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let request = TVShow.fetchRequest()
        request.predicate = NSPredicate(format: "startTime >= %@ AND startTime < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return request 
    }

    var isLive: Bool {
        guard let start = startTime, let end = endTime else { return false }
        let now = Date()
        return now >= start && now <= end
    }

    var wrappedTitle: String {
        title ?? "Untitled"
    }

    var wrappedDescription: String {
        descriptionText ?? ""
    }

    var wrappedEpisode: String {
        episode ?? ""
    }

    var channelName: String {
        channel?.wrappedName ?? "Unknown"
    }
}

