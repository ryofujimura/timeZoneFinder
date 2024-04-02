import SwiftUI

struct MainNavigationView: View {
    @State private var locations = ["Los Angeles, USA", "Honolulu, USA", "Chicago, USA", "Tokyo, Japan"]
    @State private var timeDifferences = [0, -3, 2, 16]
    @State private var emojis = ["🌴", "🌺", "🍕", "🗼"]
    @State private var globalAdjustedTime: Int = 0

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.gray.opacity(0.05))
            VStack {
                HStack {
                    Text("Timezone Finder")
                        .font(.title2)
                        .bold()
                        .padding()
                    Button(action: {}, label: {
                        Text("+")
                    })
                }
                ForEach(locations.indices, id: \.self) { city in
                    MainCityView(location: locations[city], timeDifference: timeDifferences[city], emoji: emojis[city], globalAdjustedTime: $globalAdjustedTime)
                        .id(globalAdjustedTime) // Force re-render when globalAdjustedTime changes
                }
            }
            .padding()
        }
        .padding(.vertical, 20)
    }
}

// Preview
struct MainNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        MainNavigationView()
    }
}
