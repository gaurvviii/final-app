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
        ZStack(alignment: .bottom) {
            // Main Content based on selected tab
            Group {
                if selectedTab == 0 {
                    NavigationView {
                        HomeView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                } else if selectedTab == 1 {
                    NavigationView {
                        SafetyMapView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                } else if selectedTab == 2 {
                    // Empty view for SOS
                    Color.clear
                } else if selectedTab == 3 {
                    NavigationView {
                        ResourcesView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                } else {
                    NavigationView {
                        ProfileView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80) // Reserve space for custom tab bar
            }
            
            // Custom Tab Bar - Always visible
            CustomTabBar(
                selectedTab: $selectedTab,
                showingSOS: $showingSOS
            )
        }
        .sheet(isPresented: $showingSOS) {
            SOSView()
                .environmentObject(locationManager)
        }
        .onAppear {
            // Request permissions when app launches
            locationManager.requestLocationPermissions()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showingSOS: Bool
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side tabs
            HStack(spacing: 0) {
                TabBarButton(
                    icon: "house.fill",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                TabBarButton(
                    icon: "map.fill",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
            }
            .frame(maxWidth: .infinity)
            
            // Center SOS Button
            SOSButton(isPresented: $showingSOS)
                .offset(y: -20)
            
            // Right side tabs
            HStack(spacing: 0) {
                TabBarButton(
                    icon: "shield.fill",
                    isSelected: selectedTab == 3,
                    action: { selectedTab = 3 }
                )
                
                TabBarButton(
                    icon: "person.fill",
                    isSelected: selectedTab == 4,
                    action: { selectedTab = 4 }
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(
            Rectangle()
                .fill(AppTheme.darkGray)
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? AppTheme.primaryPurple : .gray)
                
                Circle()
                    .fill(isSelected ? AppTheme.primaryPurple : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

struct SOSButton: View {
    @Binding var isPresented: Bool
    @State private var isPressed = false
    @State private var longPressProgress: CGFloat = 0
    let longPressDuration: TimeInterval = 1.0
    
    var body: some View {
        Button(action: {}) {
            Text("SOS")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(
                    ZStack {
                        Circle()
                            .fill(AppTheme.safetyRed)
                            .shadow(color: AppTheme.safetyRed.opacity(0.5), radius: isPressed ? 15 : 10)
                        
                        Circle()
                            .trim(from: 0, to: longPressProgress)
                            .stroke(Color.white, lineWidth: 3)
                            .rotationEffect(.degrees(-90))
                    }
                )
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: longPressDuration)
                .onEnded { _ in
                    isPressed = false
                    longPressProgress = 0
                    isPresented = true
                    
                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        withAnimation(.linear(duration: longPressDuration)) {
                            longPressProgress = 1
                        }
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    longPressProgress = 0
                }
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isPressed)
    }
}

struct SOSView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var locationManager: LocationManager
    @AppStorage("emergencyMessage") private var emergencyMessage = "I'm in an emergency situation and need help. Here's my current location:"
    @AppStorage("emergencyContacts") private var emergencyContactsData = Data()
    @State private var isSendingAlert = false
    @State private var showingSendError = false
    @State private var errorMessage = ""
    
    private var emergencyContacts: [EmergencyContact] {
        if let decoded = try? JSONDecoder().decode([EmergencyContact].self, from: emergencyContactsData) {
            return decoded
        }
        return []
    }
    
    private func sendEmergencyAlert() {
        // Check for location permission first
        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
            errorMessage = locationManager.lastError ?? "Location access is required. Please enable location services in Settings."
            showingSendError = true
            return
        }
        
        // Check for emergency contacts
        if emergencyContacts.isEmpty {
            errorMessage = "No emergency contacts found. Please add contacts in your profile."
            showingSendError = true
            return
        }
        
        // Start sending process
        isSendingAlert = true
        
        // Request a fresh location update
        locationManager.startUpdatingLocation()
        
        // Wait briefly for a location update
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let location = locationManager.location {
                // Format location data
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                let mapsLink = "https://www.google.com/maps?q=\(latitude),\(longitude)"
                
                // Construct the message
                let messageParts = [
                    emergencyMessage,
                    "\nCurrent Location:",
                    "Latitude: \(latitude)",
                    "Longitude: \(longitude)",
                    "\nGoogle Maps Link:",
                    mapsLink
                ]
                
                let fullMessage = messageParts.joined(separator: "\n")
                
                // Send to all contacts
                for contact in emergencyContacts {
                    sendMessage(to: contact.phone, message: fullMessage)
                }
                
                // Close the view
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isSendingAlert = false
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                // Handle location error
                isSendingAlert = false
                errorMessage = locationManager.lastError ?? "Unable to get your current location. Please try again."
                showingSendError = true
            }
        }
    }
    
    private func sendMessage(to phoneNumber: String, message: String) {
        // Format the phone number and message for URL
        let formattedPhone = phoneNumber.replacingOccurrences(of: " ", with: "")
        guard let messageEncoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "sms:\(formattedPhone)&body=\(messageEncoded)") else {
            return
        }
        
        // Open the SMS app with pre-filled message
        UIApplication.shared.open(url)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Emergency SOS")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Location Status
            VStack(alignment: .leading, spacing: 15) {
                Text("Location Status")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: locationManager.location != nil ? "location.fill" : "location.slash.fill")
                        .foregroundColor(locationManager.location != nil ? .green : .red)
                        .font(.title3)
                    
                    VStack(alignment: .leading) {
                        if let location = locationManager.location {
                            Text("Location Available")
                                .foregroundColor(.green)
                            Text("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                                .font(.caption)
                                .foregroundColor(.white)
                        } else {
                            Text(locationManager.lastError ?? "Waiting for location...")
                                .foregroundColor(.red)
                            if locationManager.authorizationStatus == .denied {
                                Button("Open Settings") {
                                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(settingsUrl)
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(AppTheme.primaryPurple)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(AppTheme.darkGray.opacity(0.6))
            .cornerRadius(15)
            .padding(.horizontal)
            
            // Emergency Contacts List
            VStack(alignment: .leading, spacing: 10) {
                Text("Emergency Contacts")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                if emergencyContacts.isEmpty {
                    Text("No emergency contacts added")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.darkGray)
                        .cornerRadius(15)
                        .padding(.horizontal)
                } else {
                    ForEach(emergencyContacts) { contact in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(contact.name)
                                    .foregroundColor(.white)
                                Text(contact.phone)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.primaryPurple)
                        }
                        .padding()
                        .background(AppTheme.darkGray)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
            
            // Send Alert Button
            Button(action: sendEmergencyAlert) {
                HStack {
                    if isSendingAlert {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                    } else {
                        Image(systemName: "bell.fill")
                            .padding(.trailing, 5)
                    }
                    
                    Text(isSendingAlert ? "Sending Emergency Alert..." : "Send Emergency Alert")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.safetyRed)
                .foregroundColor(.white)
                .cornerRadius(15)
                .padding(.horizontal)
            }
            .disabled(isSendingAlert)
        }
        .padding(.vertical)
        .background(AppTheme.nightBlack)
        .alert("Error", isPresented: $showingSendError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Request fresh location when view appears
            locationManager.startUpdatingLocation()
        }
    }
}

struct MapSnapshotView: View {
    let coordinate: CLLocationCoordinate2D
    @State private var snapshot: UIImage?
    
    var body: some View {
        Group {
            if let snapshot = snapshot {
                Image(uiImage: snapshot)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .onAppear {
            generateSnapshot()
        }
    }
    
    private func generateSnapshot() {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        options.size = CGSize(width: UIScreen.main.bounds.width - 60, height: 120)
        options.mapType = .standard
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if let snapshot = snapshot {
                self.snapshot = snapshot.image
            }
        }
    }
}

// Location Manager with real-time updates
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastError: String?
    @Published var isSimulated: Bool = false
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // Simulated location (San Francisco)
    private let simulatedLocation = CLLocation(
        coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        altitude: 0,
        horizontalAccuracy: 10,
        verticalAccuracy: 10,
        timestamp: Date()
    )
    
    override init() {
        super.init()
        print("🗺️ LocationManager initialized")
        setupLocationManager()
        
        #if DEBUG
        // Enable simulation by default in debug mode
        self.isSimulated = true
        self.useSimulatedLocation()
        #endif
    }
    
    private func useSimulatedLocation() {
        if isSimulated {
            print("🎮 Using simulated location: San Francisco")
            DispatchQueue.main.async {
                self.location = self.simulatedLocation
                self.region = MKCoordinateRegion(
                    center: self.simulatedLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                self.lastError = nil
            }
        }
    }
    
    func toggleSimulation() {
        isSimulated.toggle()
        if isSimulated {
            useSimulatedLocation()
        } else {
            // Resume real location updates
            startUpdatingLocation()
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.activityType = .otherNavigation
        
        // Get current authorization status
        authorizationStatus = locationManager.authorizationStatus
        print("📍 Current location authorization status: \(authorizationStatus.description)")
        
        // Configure based on current authorization
        configureBasedOnAuthorizationStatus()
    }
    
    func requestLocationPermissions() {
        print("🔐 Requesting location permissions...")
        locationManager.requestWhenInUseAuthorization()
        
        // Start updating immediately if we already have permission
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            print("📍 Starting immediate location updates...")
            startUpdatingLocation()
            // Request immediate one-time update
            locationManager.requestLocation()
        }
    }
    
    func startUpdatingLocation() {
        if isSimulated {
            useSimulatedLocation()
            return
        }
        
        print("🔄 Starting location updates...")
        locationManager.startUpdatingLocation()
        
        // Request an immediate location update
        locationManager.requestLocation()
        
        // Set a timer to check if we got a location
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            if self.location == nil && !self.isSimulated {
                print("⚠️ No location received after 3 seconds")
                self.lastError = "Unable to get location. Please check if location services are enabled."
                // Try requesting location again
                self.locationManager.requestLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !isSimulated, let location = locations.last else { return }
        
        // Update location
        DispatchQueue.main.async {
            self.lastError = nil // Clear any previous errors
            self.location = location
            print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            // Update region for map
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location manager failed with error: \(error.localizedDescription)")
        
        DispatchQueue.main.async {
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.lastError = "Location access denied. Please enable location services in Settings."
                case .locationUnknown:
                    self.lastError = "Unable to determine location. Please try again."
                default:
                    self.lastError = "Error getting location: \(error.localizedDescription)"
                }
            } else {
                self.lastError = "Error getting location: \(error.localizedDescription)"
            }
            
            // If it's a timeout or unknown location, try requesting location again
            if let clError = error as? CLError, clError.code == .locationUnknown {
                print("📍 Location unknown, requesting again...")
                self.locationManager.requestLocation()
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            print("🔐 Location authorization changed to: \(self.authorizationStatus.description)")
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                print("✅ Location authorization granted")
                self.lastError = nil
                self.startUpdatingLocation()
            case .denied:
                self.lastError = "Location access denied. Please enable location services in Settings."
            case .restricted:
                self.lastError = "Location access restricted. Please check your device settings."
            case .notDetermined:
                self.lastError = nil // Clear error while waiting for user input
            @unknown default:
                self.lastError = "Unknown authorization status"
            }
        }
    }
    
    private func configureBasedOnAuthorizationStatus() {
        print("⚙️ Configuring location manager based on status: \(authorizationStatus.description)")
        switch authorizationStatus {
        case .authorizedAlways:
            print("✅ Always authorization granted, setting up background updates")
            setupBackgroundLocationUpdates()
        case .authorizedWhenInUse:
            print("✅ When in use authorization granted, starting location updates")
            startUpdatingLocation()
        case .denied:
            print("❌ Location access denied by user")
        case .restricted:
            print("⚠️ Location access restricted")
        case .notDetermined:
            print("⏳ Location authorization not determined")
        @unknown default:
            print("❓ Unknown authorization status")
        }
    }
    
    private func setupBackgroundLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
        startUpdatingLocation()
        print("🔄 Background location updates configured")
    }
    
    func enableBackgroundUpdates() {
        print("🔄 Attempting to enable background updates...")
        if authorizationStatus == .authorizedWhenInUse {
            print("📱 Requesting always authorization")
            locationManager.requestAlwaysAuthorization()
        } else if authorizationStatus == .authorizedAlways {
            print("✅ Already have always authorization, setting up background updates")
            setupBackgroundLocationUpdates()
        }
    }
}

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "When in Use"
        @unknown default: return "Unknown"
        }
    }
}

// Extension to create rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Preview
#Preview {
    ContentView()
}
