//
//  CitySearchView.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 4/12/24.
//

import SwiftUI
import AppKit

struct BackBodyView: View {
    @ObservedObject var viewModel: DataModel
    @StateObject private var citySearchVM: CitySearchViewModel
    
    // Added state variables for keyboard navigation
    @State private var selectedCityIndex: Int = 0
    @FocusState private var isTextFieldFocused: Bool
    
    init(viewModel: DataModel) {
        self.viewModel = viewModel
        // Create StateObject through _citySearchVM to avoid compiler error
        _citySearchVM = StateObject(wrappedValue: CitySearchViewModel(dataModel: viewModel))
    }

    var body: some View {
        VStack(spacing: 0) {
            searchView
            middleView
            Spacer()
            settingsBottomView
        }
        // Add keyboard event handler for navigation
        .onKeyPress { press in
            handleKeyPress(press)
        }
        .onAppear {
            // Set focus to the text field when the view appears
            isTextFieldFocused = true
        }
    }

    // Search view: Search for city based on macOS time zone city data
    var searchView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(citySearchVM.showSuggestions ? .black : .gray)
                TextField("Search for a city", text: $citySearchVM.newCity)
                    .padding(.leading, 8)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(citySearchVM.showSuggestions ? .black : .gray)
                    .focused($isTextFieldFocused)
                    .onChange(of: citySearchVM.newCity) { oldValue, newValue in
                        citySearchVM.showSuggestions = !newValue.isEmpty
                        // Reset selection index when search query changes
                        selectedCityIndex = 0
                    }
                if !citySearchVM.newCity.isEmpty {
                    Button(action: {
                        citySearchVM.clearSearch()
                    }) {
                        Text("Cancel")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.leading, 8)
            .font(.system(.caption, design: .rounded).weight(.regular))
            .foregroundColor(.gray)
            .background(Color.white)
            
            // Display search history when the text field is focused and empty
            if isTextFieldFocused && citySearchVM.newCity.isEmpty && !citySearchVM.searchHistoryVM.searchHistory.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Recent Searches")
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .foregroundColor(.darkGray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    
                    ForEach(citySearchVM.searchHistoryVM.searchHistory, id: \.self) { term in
                        Button(action: {
                            citySearchVM.useHistoryItem(term)
                        }) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 12))
                                    .foregroundColor(.darkGray)
                                Text(term)
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.regular)
                                    .foregroundColor(.darkGray)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 8)
                .frame(maxHeight: 110)
            }
            
            if citySearchVM.showSuggestions {
                if citySearchVM.filteredCities.isEmpty {
                    Text("Oops. Looks like there's a typo :/")
                        .foregroundColor(Color(red: 132/256, green: 132/256, blue: 132/256).opacity(0.4))
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .frame(height: 110)
                } else {
                    ScrollView(showsIndicators: false) {
                        ScrollViewReader { scrollProxy in
                            VStack(spacing: 0) {
                                ForEach(Array(citySearchVM.filteredCities.enumerated()), id: \.element) { index, city in
                                    suggestionView(for: city)
                                        .id(index) // Add ID for ScrollViewReader
                                        .contentShape(Rectangle())
                                        .cornerRadius(25)
                                        .background(selectedCityIndex == index ? Color.lightGray : Color.clear)
                                        .cornerRadius(8)
                                        .padding(.vertical, 2)
                                        .onTapGesture {
                                            citySearchVM.addCity(city: city)
                                        }
                                }
                            }
                            .onChange(of: selectedCityIndex) { oldValue, newValue in
                                // Scroll to show the selected item when selection changes
                                withAnimation {
                                    scrollProxy.scrollTo(newValue, anchor: .center)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 110)
                    .padding(.horizontal, 8)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(8)
    }

    // Handle keyboard events
    func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        // Only handle keys when suggestions are visible
        guard citySearchVM.showSuggestions && !citySearchVM.filteredCities.isEmpty else {
            return .ignored
        }
        
        switch press.key {
        case .downArrow:
            if selectedCityIndex < citySearchVM.filteredCities.count - 1 {
                selectedCityIndex += 1
            } else {
                // Cycle back to the first item when at the end
                selectedCityIndex = 0
            }
            return .handled
            
        case .tab:
            if selectedCityIndex < citySearchVM.filteredCities.count - 1 {
                selectedCityIndex += 1
            } else {
                // Cycle back to the first item when at the end
                selectedCityIndex = 0
            }
            return .handled
            
        case .upArrow:
            if selectedCityIndex > 0 {
                selectedCityIndex -= 1
            } else {
                // Cycle to the last item when at the beginning
                selectedCityIndex = citySearchVM.filteredCities.count - 1
            }
            return .handled
            
        case .tab where press.modifiers.contains(.shift):
            if selectedCityIndex > 0 {
                selectedCityIndex -= 1
            } else {
                // Cycle to the last item when at the beginning
                selectedCityIndex = citySearchVM.filteredCities.count - 1
            }
            return .handled
            
        case .return:
            if selectedCityIndex >= 0 && selectedCityIndex < citySearchVM.filteredCities.count {
                let selectedCity = citySearchVM.filteredCities[selectedCityIndex]
                
                // Add haptic feedback if available
                #if os(macOS)
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
                #endif
                
                // Visual flash effect
                withAnimation(.easeInOut(duration: 0.15)) {
                    // This will be triggered before adding the city
                    // which clears the suggestions
                }
                
                citySearchVM.addCity(city: selectedCity)
            }
            return .handled
            
        default:
            return .ignored
        }
    }

    var middleView: some View {
        VStack(spacing: 0) {
            Text("Your List")
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundColor(.darkGray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            
            // Current location (fixed, not movable)
            HStack {
                SearchResultView(viewModel: viewModel, emoji: "📍", location: "Your Location", timeDifference: 0)
                Image(systemName: "lock")
                    .font(.system(size: 12, design: .rounded))
                    .contentShape(Rectangle())
            }
            .padding(.bottom, 8)
            
            // City list with drag and drop functionality
            if !viewModel.cityOrder.isEmpty {
                List {
                    ForEach(viewModel.cityOrder, id: \.self) { city in
                        if let cityInfo = viewModel.cityData[city] {
                            HStack {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 12))
                                    .foregroundColor(.darkGray)
                                    .padding(.trailing, 4)
                                SearchResultView(viewModel: viewModel, emoji: cityInfo.emoji, location: city, timeDifference: cityInfo.timeDifference)
                                Spacer()
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, design: .rounded))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        citySearchVM.deleteSelectedCity(city: city)
                                    }
                            }
                        }
                    }
                    .onMove(perform: viewModel.moveCity)
                }
                .listStyle(PlainListStyle())
                .frame(minHeight: 110, maxHeight: 200)
                .environment(\.defaultMinListRowHeight, 30)
            }
        }
        .padding(8)
        .cornerRadius(8)
    }

    var settingsBottomView: some View {
        VStack(spacing: 8) {
            Divider()
                .padding(.bottom, 4)
            HStack(spacing: 0) {
                Text("Settings")
                    .padding(.horizontal, 4)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                RadioOptionButton(option: "12hr", viewModel: viewModel)
                RadioOptionButton(option: "24hr", viewModel: viewModel)
                Spacer()
            }
            .padding(.horizontal, 4)
            HStack(spacing: 4) {
                Text("About    ")
                    .padding(.horizontal, 4)
                HStack(spacing: 0) {
                    Text("Designed by ")
                        .foregroundColor(.darkGray)
                    
                    Link("Moyai", destination: URL(string: "https://www.moyaifujimura.com/")!)
                        .foregroundColor(.offblack)
                    
                    Text(". Developed by ")
                        .foregroundColor(.darkGray)
                    
                    Link("Ryo", destination: URL(string: "https://github.com/ryofujimura")!)
                        .foregroundColor(.offblack)
                    
                    Text(".")
                        .foregroundColor(.darkGray)
                }
                    .padding(.horizontal, 4)
                    .fontWeight(.regular)
                Spacer()
            }
            .padding(.horizontal, 4)
            HStack(spacing: 4) {
                Text("Quit        ")
                    .padding(.horizontal, 4)
                HStack(spacing: 0) {
                    Text("Need to quit?")
                    Text(" Click here.")
                        .onTapGesture {
                            // Terminating application
                            NSApplication.shared.terminate(nil)
                        }
                }

                    .padding(.horizontal, 4)
                    .fontWeight(.regular)
                Spacer()
            }
            .padding(.horizontal, 4)
        }
        .foregroundColor(.darkGray)
        .font(.system(.caption, design: .rounded).weight(.bold))
        .padding(.bottom, 8)
    }

    func suggestionView(for city: String) -> some View {
        let emoji = citySearchVM.cityEmojis[city] ?? citySearchVM.randomEmojis.randomElement() ?? "🌍"
        let displayName = citySearchVM.displayNameForCity(city: city)

        return HStack(spacing: 8) {
            Text(emoji)
                .font(.system(.callout, design: .rounded).weight(.regular))
                .opacity(0.8)
            Text(displayName)
            Spacer()
            Text(citySearchVM.cityTime(for: city))
                .foregroundColor(.offblack)
        }
        .font(.system(.caption, design: .rounded))
        .frame(height: 17)
        .cornerRadius(20)
    }
}

// Select time format
struct RadioOptionButton: View {
    let option: String
    @ObservedObject var viewModel: DataModel

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: viewModel.timeFormat == option ? "record.circle" : "circle")
                .foregroundColor(.darkGray)
                .padding(.horizontal, 4)
            Text(option)
        }
        .fontWeight(.regular)
        .padding(.trailing, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.timeFormat = option
        }
    }
}

struct CityTimeZone: Identifiable {
    let id = UUID()
    var city: String
    var timeZoneIdentifier: String
}

#Preview {
    BackBodyView(viewModel: DataModel())
}
