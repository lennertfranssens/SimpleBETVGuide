//
//  TVShowRow.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//


import SwiftUI

struct TVShowRow: View {
    let show: TVShowModel
    @State private var showDetail = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(show.title)
                        .fontWeight(.semibold)
                    if show.isLive {
                        Text("LIVE")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(4)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
                Text(show.channelName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(timeRange)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            showDetail.toggle()
        }
        .sheet(isPresented: $showDetail) {
            TVShowDetailView(show: show)
        }
    }

    var timeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: show.startTime)) - \(formatter.string(from: show.endTime))"
    }
}