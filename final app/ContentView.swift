//
//  ContentView.swift
//  Nyx - Women's Safety App
//
//  Created by Gaurvi  on 19/03/25.
//

import SwiftUI
import CoreLocation
import AVFoundation
import MapKit

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var locationManager = LocationManager()
    @State private var showingSOS = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Main Content
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                SafetyMapView()
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .tag(1)
                
                ResourcesView()
                    .tabItem {
                        Label("Safety", systemImage: "shield.fill")
                    }
                    .tag(2)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            }
            .accentColor(AppTheme.primaryPurple)
            
            // SOS Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    SOSButton(isPresented: $showingSOS)
                        .padding()
                }
            }
        }
        .onAppear {
            // Request permissions when app launches
            locationManager.requestLocationPermissions()
        }
    }
}

struct SOSButton: View {
    @Binding var isPresented: Bool
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
            // Delay to show pressed state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isPressed = false
                isPresented.toggle()
            }
        }) {
            Text("SOS")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(AppTheme.safetyRed)
                        .shadow(color: AppTheme.safetyRed.opacity(0.5), radius: isPressed ? 15 : 10)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
}

// Location Manager with real-time updates
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // Update location every 5 meters
        
        // Get current authorization status
        authorizationStatus = locationManager.authorizationStatus
        
        // Set up based on current authorization
        configureBasedOnAuthorizationStatus()
    }
    
    func requestLocationPermissions() {
        // Request authorization
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func configureBasedOnAuthorizationStatus() {
        switch authorizationStatus {
        case .authorizedAlways:
            setupBackgroundLocationUpdates()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    private func setupBackgroundLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.startUpdatingLocation()
    }
    
    func enableBackgroundUpdates() {
        if authorizationStatus == .authorizedWhenInUse {
            // If we only have "when in use" permission, request "always" permission
            locationManager.requestAlwaysAuthorization()
        } else if authorizationStatus == .authorizedAlways {
            // If we already have "always" permission, start background updates
            setupBackgroundLocationUpdates()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update location
        self.location = location
        
        // Update region for map
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
        
        configureBasedOnAuthorizationStatus()
    }
}

// Preview
#Preview {
    ContentView()
}
