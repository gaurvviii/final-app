import SwiftUI
import MapKit

struct ResourcesView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selectors
            HStack {
                TabButton(title: "Safety Stats", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabButton(title: "Resources", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
            }
            .padding()
            .background(AppTheme.darkGray)
            
            // Tab content
            TabView(selection: $selectedTab) {
                SafetyStatsView()
                    .tag(0)
                
                ResourceContentView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(AppTheme.nightBlack)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(isSelected ? AppTheme.primaryPurple : Color.clear)
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ResourceContentView: View {
    let resources = [
        Resource(title: "Emergency Helpline", description: "Women's Helpline: 1091", icon: "phone.fill"),
        Resource(title: "Police Control Room", description: "Dial 100", icon: "building.columns.fill"),
        Resource(title: "Women's Commission", description: "State Commission for Women: 080-22100435", icon: "person.2.fill"),
        Resource(title: "Legal Aid", description: "Free legal counsel for women", icon: "doc.text.fill"),
        Resource(title: "Medical Help", description: "Emergency medical assistance", icon: "cross.case.fill"),
        Resource(title: "Shelter Homes", description: "Safe shelter for women in distress", icon: "house.fill"),
        Resource(title: "Counseling Services", description: "Professional mental health support", icon: "brain.head.profile"),
        Resource(title: "Transport Services", description: "Safe transportation options", icon: "car.fill")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Emergency Resources")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top)
                
                ForEach(resources) { resource in
                    ResourceCard(resource: resource)
                }
                
                // Nearby Police Stations
                VStack(alignment: .leading) {
                    Text("Women's Police Stations")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ForEach(bangalorePoliceStations.filter { $0.name.contains("Women") }) { station in
                        PoliceStationRow(station: station)
                    }
                    
                    Button(action: {
                        // View all stations
                    }) {
                        Text("View All Police Stations")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.primaryPurple)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .padding(.bottom, 30)
        }
        .background(AppTheme.nightBlack)
    }
}

struct Resource: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

struct ResourceCard: View {
    let resource: Resource
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: resource.icon)
                .font(.system(size: 30))
                .foregroundColor(AppTheme.primaryPurple)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(resource.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(resource.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct PoliceStationRow: View {
    let station: PoliceStation
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "building.columns.fill")
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(station.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(station.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                guard let url = URL(string: "tel:\(station.phoneNumber.replacingOccurrences(of: "-", with: ""))") else { return }
                UIApplication.shared.open(url)
            }) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                    .padding(8)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

#Preview {
    ResourcesView()
} 