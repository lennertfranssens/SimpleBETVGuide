//
//  SimpleBETVGuideApp.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//

import SwiftUI

@main
struct SimpleBETVGuideApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
