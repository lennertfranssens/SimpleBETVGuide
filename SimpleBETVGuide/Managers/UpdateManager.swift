//
//  UpdateManager.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//


import Foundation
import CoreData

class UpdateManager: ObservableObject {
    static let shared = UpdateManager()

    private let lastUpdateKey = "lastUpdateTimestamp"
    private let fetcher = XMLDataFetcher()

    func checkAndUpdateIfNeeded(context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        let now = Date()
        let todayAt18 = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: now)!

        let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date ?? .distantPast

        // If it's past 18:00 CET today AND we haven't updated since today 18:00
        if now >= todayAt18 && lastUpdate < todayAt18 {
            fetcher.fetchAndParseXML(context: context) { result in
                DispatchQueue.main.async {
                    if case .success = result {
                        UserDefaults.standard.set(now, forKey: self.lastUpdateKey)
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        } else {
            completion(false)
        }
    }

    func forceSaveLastUpdateNow() {
        UserDefaults.standard.set(Date(), forKey: lastUpdateKey)
    }
}