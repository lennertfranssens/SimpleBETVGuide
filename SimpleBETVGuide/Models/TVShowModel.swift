//
//  TVShowModel.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//


import Foundation

struct TVShowModel: Identifiable {
    var id: UUID
    var title: String
    var descriptionText: String
    var startTime: Date
    var endTime: Date
    var episode: String?
    var channelID: UUID
    var channelName: String
    var isSubscribedToEpisode: Bool {
        SubscriptionStore.shared.isSubscribed(to: self, matchTitle: false)
    }

    var isSubscribedToSeries: Bool {
        SubscriptionStore.shared.isSubscribed(to: self, matchTitle: true)
    }

    var isLive: Bool {
        let now = Date()
        return now >= startTime && now <= endTime
    }

    // For convenience when grouping by date
    var startDateOnly: Date {
        Calendar.current.startOfDay(for: startTime)
    }
}

extension TVShowModel {
    init(from entity: TVShow) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.descriptionText = entity.descriptionText ?? ""
        self.startTime = entity.startTime ?? Date()
        self.endTime = entity.endTime ?? Date()
        self.episode = entity.episode
        self.channelID = entity.channel?.id ?? UUID()
        self.channelName = entity.channel?.name ?? ""
    }
}

