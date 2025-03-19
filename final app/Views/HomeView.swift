import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var showingQuickActions = false
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.nightBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NYX")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("Stay Safe, Stay Connected")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        // User Status Indicator
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                    .frame(width: 20, height: 20)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Safety Status Card
                    SafetyStatusCard(locationManager: locationManager)
                    
                    // Quick Actions
                    QuickActionsView()
                    
                    // Recent Activity
                    RecentActivityView()
                }
                .padding(.top, 20)
            }
        }
    }
}

struct SafetyStatusCard: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Safety Status")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("Safe Zone")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            
            if let location = locationManager.location {
                // Mini Map
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )))
                .frame(height: 150)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            
            HStack(spacing: 20) {
                StatusItem(title: "Trusted Contacts", value: "3 Active")
                StatusItem(title: "Last Check", value: "2m ago")
            }
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct StatusItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct QuickActionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    QuickActionButton(title: "Fake Call", icon: "phone.fill", color: AppTheme.primaryPurple)
                    QuickActionButton(title: "Share Location", icon: "location.fill", color: AppTheme.deepBlue)
                    QuickActionButton(title: "Record", icon: "record.circle", color: AppTheme.safetyRed)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .frame(width: 100, height: 100)
            .background(color.opacity(0.2))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct RecentActivityView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(0..<3) { _ in
                ActivityRow()
            }
        }
        .padding(.horizontal)
    }
}

struct ActivityRow: View {
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(AppTheme.primaryPurple.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(AppTheme.primaryPurple)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Safety Check Completed")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("2 minutes ago")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
    }
}

#Preview {
    HomeView()
} 