//
//  XMLDataFetcher.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//

import Foundation
import CoreData

class XMLDataFetcher: NSObject, XMLParserDelegate {
    static let shared = XMLDataFetcher()
    
    private var shows: [RawTVShow] = []
    private var channels: [RawChannel] = []
    private var currentElement = ""
    private var currentShow: RawTVShow?
    private var currentChannelID = ""
    private var currentChannelName = ""

    private var currentText = ""

    // MARK: - Entry Point

    func fetchAndParseXML(context: NSManagedObjectContext, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://www.open-epg.com/files/belgium1.xml") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 2)))
                return
            }

            let parser = XMLParser(data: data)
            parser.delegate = self
            if parser.parse() {
                self.saveToCoreData(context: context)
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "Parsing failed", code: 3)))
            }
        }.resume()
    }
    
    // MARK: - Public interface for UI use
    func fetchXMLAndParse(completion: @escaping (Bool) -> Void) {
        let context = PersistenceController.shared.container.viewContext
        fetchAndParseXML(context: context) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    ChannelStore.shared.fetchChannels()
                    completion(true)
                case .failure(let error):
                    print("XML fetch failed: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }


    // MARK: - XMLParser Delegate

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentText = ""

        if elementName == "programme" {
            currentShow = RawTVShow()
            if let startString = attributeDict["start"], let endString = attributeDict["stop"] {
                currentShow?.startTime = Self.dateFromEPG(startString)
                currentShow?.endTime = Self.dateFromEPG(endString)
            }
            currentShow?.channelID = attributeDict["channel"] ?? ""
        }

        if elementName == "channel" {
            currentChannelID = attributeDict["id"] ?? ""
            currentChannelName = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "title":
            currentShow?.title = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "desc":
            currentShow?.descriptionText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "episode-num":
            currentShow?.episode = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "programme":
            if let validShow = currentShow {
                shows.append(validShow)
            }
            currentShow = nil
        case "display-name":
            currentChannelName = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "channel":
            if !currentChannelID.isEmpty && !currentChannelName.isEmpty {
                channels.append(RawChannel(id: currentChannelID, name: currentChannelName))
            }
        default:
            break
        }

        currentText = ""
    }

    // MARK: - Save to Core Data

    private func saveToCoreData(context: NSManagedObjectContext) {
        context.performAndWait {
            // Remove existing data
            let fetch1 = NSFetchRequest<NSFetchRequestResult>(entityName: "TVShow")
            let fetch2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
            let batchDelete1 = NSBatchDeleteRequest(fetchRequest: fetch1)
            let batchDelete2 = NSBatchDeleteRequest(fetchRequest: fetch2)
            _ = try? context.execute(batchDelete1)
            _ = try? context.execute(batchDelete2)

            // Save channels
            var channelMap: [String: Channel] = [:]
            for raw in self.channels {
                let channel = Channel(context: context)
                channel.id = UUID()
                channel.name = raw.name
                channel.isFavorite = false
                channelMap[raw.id] = channel
            }

            // Save shows
            for raw in self.shows {
                let show = TVShow(context: context)
                show.id = UUID()
                show.title = raw.title
                show.descriptionText = raw.descriptionText
                show.episode = raw.episode
                show.startTime = raw.startTime
                show.endTime = raw.endTime
                show.isSubscribedToEpisode = false
                show.isSubscribedToTitle = false
                show.channel = channelMap[raw.channelID]
            }

            do {
                try context.save()
                print("Saved channels to Core Data")
            } catch {
                print("Failed to save channels: \(error)")
            }
        }
    }

    // MARK: - EPG Date Parsing

    static func dateFromEPG(_ string: String) -> Date {
        // Example format: 20250606204000 +0200
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss ZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        // If timezone missing, default to CET
        if string.count > 14 {
            return formatter.date(from: string) ?? Date.distantPast
        } else {
            formatter.timeZone = TimeZone(abbreviation: "CET")
            return formatter.date(from: string + " +0100") ?? Date.distantPast
        }
    }
}

struct RawTVShow {
    var title: String = ""
    var descriptionText: String = ""
    var startTime: Date = .distantPast
    var endTime: Date = .distantPast
    var channelID: String = ""
    var episode: String = ""
}

struct RawChannel {
    var id: String
    var name: String
}
