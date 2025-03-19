import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explore Safely")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Navigate with confidence, anytime, anywhere")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search safe locations...", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding()
                .background(AppTheme.darkGray)
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Quick Access Locations
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Safe Locations Nearby")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Button("View All") {
                            // Action
                        }
                        .foregroundColor(AppTheme.primaryPurple)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(safePlaces) { place in
                                SafeLocationCard(place: place)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Safety Features
                VStack(alignment: .leading, spacing: 15) {
                    Text("Safety Features")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            SafetyFeatureCard(
                                title: "Live Location",
                                description: "Share your real-time location",
                                icon: "location.fill",
                                color: AppTheme.deepBlue
                            )
                            
                            SafetyFeatureCard(
                                title: "SOS Alert",
                                description: "Quick emergency assistance",
                                icon: "bell.fill",
                                color: AppTheme.safetyRed
                            )
                            
                            SafetyFeatureCard(
                                title: "Safe Routes",
                                description: "Navigate through safe paths",
                                icon: "map.fill",
                                color: AppTheme.primaryPurple
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Navigation Bar
                NavigationBar(selectedTab: .constant(0))
                    .padding(.top)
            }
            .padding(.top, 20)
        }
        .background(AppTheme.nightBlack)
    }
}

struct SafeLocationCard: View {
    let place: SafePlace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 15)
                .fill(AppTheme.darkGray)
                .frame(width: 200, height: 120)
                .overlay(
                    Image(systemName: "shield.fill")
                        .foregroundColor(AppTheme.primaryPurple)
                        .font(.system(size: 30))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(place.address)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .frame(width: 200)
    }
}

struct SafetyFeatureCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(width: 160, height: 140)
        .background(AppTheme.darkGray)
        .cornerRadius(15)
    }
}

struct NavigationBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            ForEach(0..<4) { index in
                Spacer()
                Button(action: { selectedTab = index }) {
                    VStack(spacing: 4) {
                        Image(systemName: getIcon(for: index))
                            .foregroundColor(selectedTab == index ? AppTheme.primaryPurple : .gray)
                        Text(getTitle(for: index))
                            .font(.caption2)
                            .foregroundColor(selectedTab == index ? AppTheme.primaryPurple : .gray)
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .background(AppTheme.darkGray)
        .cornerRadius(25)
        .padding(.horizontal)
    }
    
    private func getIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "map.fill"
        case 2: return "bell.fill"
        case 3: return "person.fill"
        default: return ""
        }
    }
    
    private func getTitle(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Map"
        case 2: return "Alerts"
        case 3: return "Profile"
        default: return ""
        }
    }
}

#Preview {
    HomeView()
} 