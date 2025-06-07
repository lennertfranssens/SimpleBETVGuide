//
//  ChannelModel.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//


import Foundation

struct ChannelModel: Identifiable {
    var id: UUID
    var name: String
    var isFavorite: Bool
}

extension ChannelModel {
    init(from entity: Channel) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.isFavorite = entity.isFavorite
    }
}
