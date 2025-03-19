import SwiftUI

struct SafetyStatsView: View {
    @StateObject private var crimeDataService = CrimeDataService()
    @State private var selectedCategory = "All"
    @State private var selectedCity = "Bangalore"
    
    private let categories = ["All", "Travel", "Areas", "Night Safety", "Transportation"]
    private let availableCities = ["Bangalore", "Delhi", "Mumbai", "Chennai", "Kolkata"]
    
    // Dynamic crime statistics from the service
    private var crimeStats: [CrimeStat] {
        // If data is still loading, show placeholder stats
        if crimeDataService.isLoading {
            return [
                CrimeStat(
                    title: "Loading Data...",
                    value: "Please wait",
                    icon: "ellipsis",
                    color: .gray
                )
            ]
        }
        
        // If there was an error, show error state
        if let error = crimeDataService.errorMessage {
            return [
                CrimeStat(
                    title: "Data Error",
                    value: error,
                    icon: "exclamationmark.triangle",
                    color: .red
                )
            ]
        }
        
        // Filter hotspots for selected city
        let cityHotspots = crimeDataService.crimeHotspots.filter { $0.city == selectedCity }
        
        if cityHotspots.isEmpty {
            return [
                CrimeStat(
                    title: "No Data Available",
                    value: "No crime data for \(selectedCity)",
                    icon: "magnifyingglass",
                    color: .gray
                )
            ]
        }
        
        // Most dangerous areas (highest crime count)
        let dangerousAreas = cityHotspots.sorted { $0.crimeCount > $1.crimeCount }
            .prefix(3)
            .map { $0.area }
            .joined(separator: ", ")
        
        // Peak crime hours based on time patterns
        let timeDistribution = cityHotspots.reduce(into: [TimePattern: Int]()) { result, hotspot in
            result[hotspot.timePattern, default: 0] += hotspot.crimeCount
        }
        
        let peakTimePeriod = timeDistribution.max { $0.value < $1.value }?.key.rawValue ?? "Unknown"
        
        // Most common crime types
        let crimeCounts = cityHotspots.flatMap { $0.crimeTypes }
            .reduce(into: [String: Int]()) { result, type in
                result[type, default: 0] += 1
            }
        
        let commonCrimes = crimeCounts.sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
            .joined(separator: ", ")
        
        // Calculate safest transport based on crime patterns
        let safeTransport = cityHotspots.filter { $0.timePattern == .night }.count > cityHotspots.filter { $0.timePattern == .day }.count
            ? "Metro Stations & App-based Cabs"
            : "Public Buses during Daytime"
        
        return [
            CrimeStat(
                title: "Most Reported Areas",
                value: dangerousAreas,
                icon: "map.fill",
                color: .red
            ),
            CrimeStat(
                title: "Peak Crime Hours",
                value: peakTimePeriod,
                icon: "clock.fill",
                color: .orange
            ),
            CrimeStat(
                title: "Safest Public Transport",
                value: safeTransport,
                icon: "tram.fill",
                color: .green
            ),
            CrimeStat(
                title: "Most Common Incidents",
                value: commonCrimes.isEmpty ? "Data Unavailable" : commonCrimes,
                icon: "exclamationmark.triangle.fill",
                color: .red
            )
        ]
    }
    
    // Generate safety tips based on crime data
    private var dataDrivenTips: [String] {
        let cityHotspots = crimeDataService.crimeHotspots.filter { $0.city == selectedCity }
        
        if cityHotspots.isEmpty {
            return []
        }
        
        var tips: [String] = []
        
        // Areas with high risk levels
        let highRiskAreas = cityHotspots.filter { $0.riskLevel == .high }
        if !highRiskAreas.isEmpty {
            let areaNames = highRiskAreas.prefix(3).map { $0.area }.joined(separator: ", ")
            tips.append("Avoid \(areaNames) areas, especially at night - these have the highest reported incident rates.")
        }
        
        // Night safety based on time patterns
        if cityHotspots.filter({ $0.timePattern == .night }).count > cityHotspots.filter({ $0.timePattern == .day }).count {
            tips.append("Most incidents in \(selectedCity) occur at night between 9PM-5AM. Use extra caution during these hours.")
        }
        
        // Common crime types tips
        let crimeTypes = Set(cityHotspots.flatMap { $0.crimeTypes })
        if crimeTypes.contains("Theft") || crimeTypes.contains("Robbery") {
            tips.append("Keep valuables hidden and secure your bag in crowded areas to prevent theft incidents.")
        }
        if crimeTypes.contains("Harassment") || crimeTypes.contains("Stalking") {
            tips.append("If being followed, enter a public place with security personnel and use the SOS feature immediately.")
        }
        
        return tips
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("Safety Intelligence")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Menu {
                        ForEach(availableCities, id: \.self) { city in
                            Button(city) {
                                selectedCity = city
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCity)
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .foregroundColor(AppTheme.primaryPurple)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.darkGray)
                        .cornerRadius(20)
                    }
                }
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
                    
                    if crimeDataService.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primaryPurple))
                                .scaleEffect(1.5)
                            Spacer()
                        }
                        .padding(.vertical, 30)
                    } else {
                        ForEach(crimeStats) { stat in
                            CrimeStatCard(stat: stat)
                        }
                    }
                }
                
                // Data-driven tips
                if !dataDrivenTips.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Data-Driven Safety Tips")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(dataDrivenTips, id: \.self) { tip in
                            SafetyTipRow(tip: tip, iconName: "chart.bar.fill")
                        }
                    }
                    .padding(.top, 10)
                }
                
                // General Safety Tips Section
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
        .onAppear {
            crimeDataService.fetchCrimeData()
        }
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
    var iconName: String = "checkmark.shield.fill"
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
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