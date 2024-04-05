//
//  CitySearchView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/4/24.
//

import SwiftUI

struct CitySearchView: View {
    @State private var searchText: String = ""
    @State private var showSuggestions: Bool = false

    var filteredTimeZones: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return TimeZone.knownTimeZoneIdentifiers.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack {
            TextField("Search Timezones", text: $searchText)
                .onChange(of: searchText) { newSearchText in
                    showSuggestions = !newSearchText.isEmpty
                }
                .modifier(TextFieldClearButton(text: $searchText))

            if showSuggestions {
                List {
                    ForEach(filteredTimeZones, id: \.self) { identifier in
                        Text(formatTimeZone(identifier: identifier))
                            .onTapGesture {
                                searchText = formatTimeZone(identifier: identifier)
                                showSuggestions = false
                            }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
//        .padding()
    }

    func formatTimeZone(identifier: String) -> String {
        let components = identifier.split(separator: "/")
        let city = components.last?.replacingOccurrences(of: "_", with: " ") ?? ""
        let country = components.first ?? ""
        return "\(city), \(country.prefix(3))"
    }
}

struct TextFieldClearButton: ViewModifier {
    @Binding var text: String

    func body(content: Content) -> some View {
        HStack {
            content
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.secondary)
                }
                .padding(.trailing, 8)
            }
        }
    }
}



#Preview {
    CitySearchView()
}
