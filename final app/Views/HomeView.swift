import SwiftUI
import MapKit
import UIKit

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var showLocationPermissionAlert = false
    
    // Add access to safePlaces data
    private let nearbyPlaces = safePlaces
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nyx")
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
                            ForEach(nearbyPlaces) { place in
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
                            .onTapGesture {
                                checkLocationPermission()
                            }
                            
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
                
                // Location Status Card
                if let location = locationManager.location {
                    LocationStatusCard(coordinate: location.coordinate)
                        .padding(.horizontal)
                        .padding(.top, 10)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 80) // Add padding at bottom to avoid tab bar overlap
        }
        .background(AppTheme.nightBlack)
        .alert(isPresented: $showLocationPermissionAlert) {
            Alert(
                title: Text("Location Access Needed"),
                message: Text("Please enable location access in Settings to use all safety features."),
                primaryButton: .default(Text("Settings"), action: openSettings),
                secondaryButton: .cancel()
            )
        }
    }
    
    private func checkLocationPermission() {
        if locationManager.authorizationStatus == .denied || 
           locationManager.authorizationStatus == .restricted {
            showLocationPermissionAlert = true
        } else if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestLocationPermissions()
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct LocationStatusCard: View {
    let coordinate: CLLocationCoordinate2D
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.green)
                Text("Location tracking active")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Text("Updated just now")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latitude")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.4f", coordinate.latitude))
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Longitude")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.4f", coordinate.longitude))
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
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

#Preview {
    HomeView()
} 