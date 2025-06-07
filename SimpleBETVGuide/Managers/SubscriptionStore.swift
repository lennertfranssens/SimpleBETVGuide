//
//  SubscriptionStore.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//


import Foundation
import CoreData

class SubscriptionStore {
    static let shared = SubscriptionStore()

    private let context = PersistenceController.shared.container.viewContext

    func isSubscribed(to show: TVShowModel, matchTitle: Bool) -> Bool {
        let request: NSFetchRequest<SimpleBETVGuide.Subscription> = Subscription.fetchRequest()

        let idPredicate = NSPredicate(format: "tvShowID == %@", show.id as CVarArg)
        let titlePredicate = NSPredicate(format: "title == %@", show.title)

        request.predicate = matchTitle ? titlePredicate : idPredicate

        return (try? context.count(for: request)) ?? 0 > 0
    }

    func subscribe(to show: TVShowModel, matchTitle: Bool) {
        let sub = Subscription(context: context)
        sub.id = UUID()
        sub.tvShowID = matchTitle ? nil : show.id
        sub.title = show.title
        try? context.save()
    }

    func unsubscribe(from show: TVShowModel, matchTitle: Bool) {
        let request: NSFetchRequest<Subscription> = Subscription.fetchRequest()

        let predicate = matchTitle
            ? NSPredicate(format: "title == %@", show.title)
            : NSPredicate(format: "tvShowID == %@", show.id as CVarArg)

        request.predicate = predicate

        if let results = try? context.fetch(request) {
            for sub in results {
                context.delete(sub)
            }
            try? context.save()
        }
    }

    func toggleSubscription(for show: TVShowModel, matchTitle: Bool) {
        if isSubscribed(to: show, matchTitle: matchTitle) {
            unsubscribe(from: show, matchTitle: matchTitle)
        } else {
            subscribe(to: show, matchTitle: matchTitle)
        }
    }
}
