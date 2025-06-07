//
//  Persistence.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//

import CoreData


struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "SimpleBETVGuide")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error: \(error)")
            }
        }
    }
}
