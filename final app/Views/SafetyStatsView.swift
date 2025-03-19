import SwiftUI

struct SafetyStatsView: View {
    @State private var selectedCategory = "All"
    
    private let categories = ["All", "Travel", "Areas", "Night Safety", "Transportation"]
    
    // Crime statistics insights from the data
    private let crimeStats = [
        CrimeStat(
            title: "Most Reported Areas",
            value: "Majestic, K.R. Market, Shivajinagar",
            icon: "map.fill",
            color: .red
        ),
        CrimeStat(
            title: "Peak Crime Hours",
            value: "8PM - 2AM",
            icon: "clock.fill",
            color: .orange
        ),
        CrimeStat(
            title: "Safest Public Transport",
            value: "Metro Stations & Routes",
            icon: "tram.fill",
            color: .green
        ),
        CrimeStat(
            title: "Most Common Incidents",
            value: "Harassment, Theft, Stalking",
            icon: "exclamationmark.triangle.fill",
            color: .red
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Safety Intelligence")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                // Safety Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(
                                title: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Crime Statistics
                VStack(alignment: .leading, spacing: 10) {
                    Text("Crime Statistics")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ForEach(crimeStats) { stat in
                        CrimeStatCard(stat: stat)
                    }
                }
                
                // Safety Tips Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Safety Tips")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ForEach(getFilteredTips(for: selectedCategory), id: \.self) { tip in
                        SafetyTipRow(tip: tip)
                    }
                }
                .padding(.top, 10)
            }
            .padding(.vertical)
        }
        .background(AppTheme.nightBlack)
    }
    
    private func getFilteredTips(for category: String) -> [String] {
        if category == "All" {
            return Array(safetyTips.values.flatMap { $0 }).shuffled().prefix(8).map { $0 }
        } else {
            return safetyTips[category] ?? []
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primaryPurple : AppTheme.darkGray)
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
        }
    }
}

struct CrimeStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}

struct CrimeStatCard: View {
    let stat: CrimeStat
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: stat.icon)
                .font(.system(size: 28))
                .foregroundColor(stat.color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(stat.value)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct SafetyTipRow: View {
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(AppTheme.primaryPurple)
                .font(.system(size: 18))
            
            Text(tip)
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(nil)
            
            Spacer()
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

// Safety tips organized by category
let safetyTips: [String: [String]] = [
    "Travel": [
        "Avoid wearing expensive jewelry or showing valuables in public areas.",
        "Keep your phone hidden in crowded areas, especially in markets.",
        "Share your live location with trusted contacts when traveling alone.",
        "Avoid remote or poorly lit areas, especially between 9 PM and 5 AM.",
        "Use the 'Nyx SOS' feature to quickly alert emergency contacts."
    ],
    "Areas": [
        "Be extra vigilant in Majestic, K.R. Market, and Shivajinagar areas at night.",
        "The safest shopping areas are within malls with security personnel.",
        "Station areas have higher theft rates - keep valuables secure.",
        "Check the safety map before visiting unfamiliar neighborhoods.",
        "Use Nyx's real-time crime reporting to check for recent incidents in an area."
    ],
    "Night Safety": [
        "Use well-lit, busy streets even if your route becomes slightly longer.",
        "Book cabs through apps that track your journey rather than roadside taxis.",
        "Note the vehicle registration number before entering any public transport.",
        "Have your keys ready before you reach your home entrance.",
        "Use the 'Walk with Me' feature in Nyx when walking in secluded areas at night."
    ],
    "Transportation": [
        "Metro stations are generally safer waiting areas than bus stands at night.",
        "Prefer women-only compartments in trains during late hours.",
        "Take photos of auto/taxi registration and share with family before long rides.",
        "Avoid empty or nearly empty public transportation, especially after dark.",
        "Use the 'Safer Route' feature in Nyx to plan your journey through well-lit areas."
    ]
]

#Preview {
    SafetyStatsView()
} 