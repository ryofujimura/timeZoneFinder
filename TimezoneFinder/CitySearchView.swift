//
//  CitySearchView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/4/24.
//

import SwiftUI

// MARK: - Timezone Detail Model
struct TimezoneDetail: Identifiable {
    let id = UUID()
    var identifier: String
    var city: String
    var country: String
    var timeDifference: String
}

// MARK: - City Search View
struct CitySearchView: View {
    @State private var searchText = ""
    @State private var searchResults = [String]()
    @State private var showResults = false
    
    var body: some View {
        VStack {
            TextField("Search for a timezone", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText) {
                    searchTimezone(query: searchText)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
                    self.showResults = false
                }

            if showResults && !searchResults.isEmpty {
                List(searchResults, id: \.self) { result in
                    Text(result).onTapGesture {
                        self.selectTimezone(identifier: result)
                        self.showResults = false
                    }
                }
//                .frame(maxHeight: 200)
                .border(Color.gray, width: 1)
            }
        }
        .frame(height: 1000)
    }

    private func searchTimezone(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            showResults = false
            return
        }
        searchResults = TimeZone.knownTimeZoneIdentifiers.filter { $0.localizedCaseInsensitiveContains(query) }
        showResults = true
    }

    private func selectTimezone(identifier: String) {
        // Handle the selection, potentially updating the UI or performing other actions
        print("Selected timezone: \(identifier)")
    }
}


#Preview {
    CitySearchView()
}
