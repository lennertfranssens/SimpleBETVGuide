//
//  ChannelsView.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//


import SwiftUI

struct ChannelsView: View {
    @StateObject private var store = ChannelStore.shared

    var body: some View {
        NavigationView {
            List {
                ForEach(store.channels, id: \.self) { channel in
                    HStack {
                        Text(channel.name ?? "Unknown")
                        Spacer()
                        Image(systemName: channel.isFavorite ? "star.fill" : "star")
                            .foregroundColor(channel.isFavorite ? .yellow : .gray)
                            .onTapGesture {
                                store.toggleFavorite(channel: channel)
                            }
                    }
                }
            }
            .navigationTitle("Channels")
            .onAppear {
                store.fetchChannels()
            }
        }
    }
}
