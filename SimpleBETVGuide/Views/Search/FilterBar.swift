//
//  FilterBar.swift
//  SimpleBETVGuide
//
//  Created by Lennert Franssens on 07/06/2025.
//


import SwiftUI

struct FilterBar: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        VStack(spacing: 8) {
            // Channel Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button("All") {
                        viewModel.selectedChannel = nil
                    }
                    .buttonStyle(FilterButtonStyle(isSelected: viewModel.selectedChannel == nil))

                    ForEach(viewModel.availableChannels, id: \.self) { channel in
                        Button(channel) {
                            viewModel.selectedChannel = channel
                        }
                        .buttonStyle(FilterButtonStyle(isSelected: viewModel.selectedChannel == channel))
                    }
                }
                .padding(.horizontal)
            }

            // Date Filter
            Picker("Date", selection: $viewModel.selectedDate) {
                Text("All").tag(nil as Date?)
                ForEach(viewModel.dateOptions, id: \.self) { date in
                    Text(Self.dateLabel(for: date)).tag(date as Date?)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
        }
    }

    static func dateLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

struct FilterButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(8)
            .foregroundColor(isSelected ? .accentColor : .primary)
    }
}