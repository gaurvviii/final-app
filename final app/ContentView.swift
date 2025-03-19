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
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                SafetyMapView()
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Map")
                    }
                    .tag(1)
                
                ResourcesView()
                    .tabItem {
                        Image(systemName: "shield.fill")
                        Text("Safety")
                    }
                    .tag(2)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(3)
            }
            .accentColor(AppTheme.primaryPurple)
            
            // SOS Button
            VStack {
                HStack {
                    Spacer()
                    SOSButton(isPresented: $showingSOS)
                        .padding(.top, 60)
                        .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// SOS Button View
struct SOSButton: View {
    @Binding var isPresented: Bool
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed.toggle()
            }
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
        
        // Request authorization first
        locationManager.requestWhenInUseAuthorization()
        
        // Only enable background updates after authorization is granted
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .authorizedAlways:
                enableBackgroundUpdates()
            case .authorizedWhenInUse:
                locationManager.requestAlwaysAuthorization()
            default:
                break
            }
        }
    }
    
    private func enableBackgroundUpdates() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.startUpdatingLocation()
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
        
        // Log location update for debugging
        print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            enableBackgroundUpdates()
        case .authorizedWhenInUse:
            // Request "Always" authorization if we only have "When in Use"
            manager.requestAlwaysAuthorization()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Handle denied access
            print("Location access denied or restricted")
        @unknown default:
            break
        }
    }
}

// Preview
#Preview {
    ContentView()
}
