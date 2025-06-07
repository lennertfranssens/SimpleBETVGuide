//
//  ChannelStore.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//


import Foundation
import CoreData

class ChannelStore: ObservableObject {
    static let shared = ChannelStore()

    private let context = PersistenceController.shared.container.viewContext

    @Published var channels: [Channel] = []

    func fetchChannels() {
        let request: NSFetchRequest<Channel> = Channel.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Channel.name, ascending: true)]
        do {
            channels = try context.fetch(request)
        } catch {
            print("Failed to fetch channels: \(error)")
            channels = []
        }
    }

    func toggleFavorite(channel: Channel) {
        channel.isFavorite.toggle()
        try? context.save()
        fetchChannels() // Refresh list
    }
}
