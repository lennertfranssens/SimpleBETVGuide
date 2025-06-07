//
//  ContentView.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            TVGuideView()
                .tabItem { Label("TV Guide", systemImage: "tv") }

            ChannelsView()
                .tabItem { Label("Channels", systemImage: "list.bullet") }

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}
