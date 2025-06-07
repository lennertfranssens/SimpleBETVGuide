//
//  TVGuideContentView.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//


import SwiftUI

struct TVGuideContentView: View {
    var shows: [TVShowModel]

    var body: some View {
        ScrollViewReader { proxy in
            List(shows) { show in
                TVShowRow(show: show)
                    .id(show.id)
            }
            .onAppear {
                scrollToCurrent(proxy: proxy)
            }
        }
    }

    func scrollToCurrent(proxy: ScrollViewProxy) {
        if let now = shows.first(where: { $0.isLive }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                proxy.scrollTo(now.id, anchor: .center)
            }
        }
    }
}