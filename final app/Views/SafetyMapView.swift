import SwiftUI
import MapKit
import MessageUI

struct SafetyMapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var policeDataService = PoliceDataService()
    @StateObject private var metroDataService = MetroDataService()
    @StateObject private var crimeDataService = CrimeDataService()
    @StateObject private var newsDataService = NewsDataService()
    
    @State private var selectedCity = "Bangalore"
    @State private var filterTimeOfDay: TimePattern?
    @State private var selectedYear: Int?
    @State private var showingSosAlert = false
    @State private var showingEmergencyContacts = false
    @State private var isNightMode = false
    @State private var showPoliceStations = true
    @State private var showMetroStations = true
    @State private var showCrimeHotspots = true
    @State private var showCrimeNews = true
    
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    
    // Add zoom level state
    @State private var currentZoomLevel: Double = 0.05
    private let minZoomLevel: Double = 0.01
    private let maxZoomLevel: Double = 0.5
    
    private let availableCities = ["Bangalore", "Delhi", "Mumbai", "Chennai", "Kolkata"]
    private let emergencyNumbers = [
        ("Police", "100"),
        ("Women's Helpline", "1091"),
        ("Ambulance", "108"),
        ("Fire", "101")
    ]
    
    private var defaultLocation: CLLocation {
        CLLocation(
            latitude: cityCoordinates[selectedCity]?.latitude ?? 12.9716,
            longitude: cityCoordinates[selectedCity]?.longitude ?? 77.5946
        )
    }
    
    private var nearestStations: [PoliceStation] {
        let location = locationManager.location ?? defaultLocation
        print("📍 Using location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        let stations = policeDataService.getNearbyPoliceStations(to: location)
        print("📍 Found \(stations.count) police stations")
        return stations
    }
    
    private var nearestMetroStations: [MetroStation] {
        let location = locationManager.location ?? defaultLocation
        let stations = metroDataService.getNearbyMetroStations(to: location)
        print("🚇 Found \(stations.count) metro stations")
        return stations
    }
    
    private var nearbyCrimeHotspots: [CrimeHotspot] {
        let location = locationManager.location ?? defaultLocation
        
        var hotspots = crimeDataService.getHotspots(for: selectedCity)
        print("🚨 Found \(hotspots.count) crime hotspots for \(selectedCity)")
        
        if let timeFilter = filterTimeOfDay {
            hotspots = hotspots.filter { $0.timePattern == timeFilter || $0.timePattern == .allDay }
            print("⏰ Filtered to \(hotspots.count) hotspots for time pattern: \(timeFilter)")
        }
        
        return hotspots
    }
    
    private func handleSOS() {
        // First check location authorization
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // Request location permission first
            locationManager.requestLocationPermissions()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Show alert after requesting permission
                showingSosAlert = true
            }
            
        case .restricted, .denied:
            // Show alert with warning about location access
            showingSosAlert = true
            print("⚠️ Location access not granted. Using default location.")
            
        case .authorizedWhenInUse, .authorizedAlways:
            if locationManager.location == nil {
                // Start updating location if we don't have one
                print("📍 Requesting immediate location update...")
                locationManager.locationManager.startUpdatingLocation()
                
                // Wait briefly for location update
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingSosAlert = true
                }
            } else {
                showingSosAlert = true
            }
            
        @unknown default:
            showingSosAlert = true
        }
    }
    
    private func sendSOSToContacts() {
        if let contacts = try? JSONDecoder().decode([EmergencyContact].self, from: UserDefaults.standard.data(forKey: "emergencyContacts") ?? Data()) {
            let location = locationManager.location?.coordinate ?? defaultLocation.coordinate
            print("📍 Sending SOS with location: \(location.latitude), \(location.longitude)")
            
            for contact in contacts {
                let message = contact.generateSOSMessage(location: location)
                if let url = URL(string: "sms:\(contact.phone)&body=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
    
    private func initializeServices() {
        print("🚀 Initializing services...")
        locationManager.requestLocationPermissions()
        
        // Initialize with default location if user location is not available
        let location = locationManager.location ?? defaultLocation
        print("📍 Initializing services with location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        crimeDataService.fetchCrimeData()
        policeDataService.loadPoliceStations()
        metroDataService.loadMetroStations()
        
        // Fetch news with retry logic
        fetchNewsWithRetry()
    }
    
    private func fetchNewsWithRetry() {
        let location = locationManager.location ?? defaultLocation
        newsDataService.fetchCrimeNews(userLocation: location) { result in
            switch result {
            case .success(let news):
                print("📰 Loaded \(news.count) news items")
                // Update map region to show all news items
                if !news.isEmpty {
                    updateMapRegionForNews(news)
                }
            case .failure(let error):
                print("❌ Failed to load news: \(error.localizedDescription)")
                // Retry after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    fetchNewsWithRetry()
                }
            }
        }
    }
    
    private func zoomOut() {
        withAnimation {
            currentZoomLevel = min(currentZoomLevel * 2, maxZoomLevel)
            if let region = cameraPosition.region {
                cameraPosition = .region(MKCoordinateRegion(
                    center: region.center,
                    span: MKCoordinateSpan(
                        latitudeDelta: currentZoomLevel,
                        longitudeDelta: currentZoomLevel
                    )
                ))
            }
        }
    }
    
    private func zoomIn() {
        withAnimation {
            currentZoomLevel = max(currentZoomLevel / 2, minZoomLevel)
            if let region = cameraPosition.region {
                cameraPosition = .region(MKCoordinateRegion(
                    center: region.center,
                    span: MKCoordinateSpan(
                        latitudeDelta: currentZoomLevel,
                        longitudeDelta: currentZoomLevel
                    )
                ))
            }
        }
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                // User Location
                if let location = locationManager.location {
                    UserAnnotation()
                } else {
                    // Show a marker at the default location when user location is not available
                    let defaultCoord = defaultLocation.coordinate
                    Annotation("Default Location", coordinate: defaultCoord) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray)
                            .clipShape(Circle())
                    }
                }
                
                // Police Station Markers with Safe Zone Overlays
                if showPoliceStations {
                    ForEach(nearestStations) { station in
                        // Safe zone overlay
                        MapCircle(center: station.coordinate, radius: 500) // 500 meters radius
                            .foregroundStyle(.green.opacity(0.1))
                            .stroke(.green, lineWidth: 1)
                        
                        // Station marker
                        Annotation("Police Station: \(station.name)", coordinate: station.coordinate) {
                            Image(systemName: "building.columns.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                }
                
                // Metro Station Markers with Safe Zone Overlays
                if showMetroStations {
                    ForEach(nearestMetroStations) { station in
                        // Safe zone overlay
                        MapCircle(center: station.coordinate, radius: 400) // 400 meters radius
                            .foregroundStyle(.green.opacity(0.1))
                            .stroke(.green, lineWidth: 1)
                        
                        // Station marker
                        Annotation("Metro Station: \(station.name)", coordinate: station.coordinate) {
                            Image(systemName: "tram.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.purple)
                                .clipShape(Circle())
                        }
                    }
                }
                
                // Crime Hotspots with Overlays
                if showCrimeHotspots {
                    ForEach(nearbyCrimeHotspots) { hotspot in
                        // Risk zone overlay
                        MapCircle(center: hotspot.coordinate, radius: 300)  // 300 meters radius
                            .foregroundStyle(.red.opacity(0.15))
                            .stroke(.red, lineWidth: 1)
                        
                        // Hotspot marker
                        Annotation("Crime Hotspot: \(hotspot.area)", coordinate: hotspot.coordinate) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                    }
                }
                
                // Crime News Markers with Overlays
                if showCrimeNews {
                    ForEach(newsDataService.crimeNews.filter { $0.coordinates != nil }) { news in
                        // Incident zone overlay
                        MapCircle(center: news.coordinates, radius: 500)  // 500 meters radius
                            .foregroundStyle(.orange.opacity(0.2))
                            .stroke(.orange, lineWidth: 2)
                        
                        // News marker with callout
                        Annotation(news.title, coordinate: news.coordinates) {
                            VStack(spacing: 4) {
                                Image(systemName: "newspaper.fill")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                                
                                // Callout view
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(news.title)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                    
                                    Text(news.description)
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .lineLimit(3)
                                    
                                    HStack {
                                        Text(news.source)
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Spacer()
                                        
                                        Text("\(Int(news.distance / 1000))km away")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                .padding(8)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(8)
                                .frame(maxWidth: 200)
                            }
                        }
                    }
                }
            }
            .mapStyle(isNightMode ? .hybrid : .standard)
            .mapControls {
                MapCompass()
                MapScaleView()
                MapUserLocationButton()
            }
            
            // Navigation Overlay
            VStack(spacing: 0) {
                // Top Bar
                VStack(spacing: 12) {
                    // Menu and Night Mode
                    HStack {
                        Menu {
                            Picker("City", selection: $selectedCity) {
                                ForEach(availableCities, id: \.self) { city in
                                    Text(city).tag(city)
                                }
                            }
                            
                            Menu("Time of Day") {
                                Button("All Times") {
                                    filterTimeOfDay = nil
                                }
                                Button("Night (9PM - 5AM)") {
                                    filterTimeOfDay = .night
                                }
                                Button("Evening (5PM - 9PM)") {
                                    filterTimeOfDay = .evening
                                }
                                Button("Day (5AM - 5PM)") {
                                    filterTimeOfDay = .day
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(AppTheme.primaryPurple)
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        // Zoom Controls
                        HStack(spacing: 8) {
                            Button(action: zoomIn) {
                                Image(systemName: "minus.magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(AppTheme.primaryPurple)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: zoomOut) {
                                Image(systemName: "plus.magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(AppTheme.primaryPurple)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Button(action: {
                            isNightMode.toggle()
                        }) {
                            Image(systemName: isNightMode ? "sun.max.fill" : "moon.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(AppTheme.primaryPurple)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Toggle Buttons
                    HStack(spacing: 8) {
                        ToggleButton(
                            isOn: $showPoliceStations,
                            icon: "building.columns.fill",
                            label: "Police"
                        )
                        
                        ToggleButton(
                            isOn: $showMetroStations,
                            icon: "tram.fill",
                            label: "Metro"
                        )
                        
                        ToggleButton(
                            isOn: $showCrimeHotspots,
                            icon: "exclamationmark.triangle.fill",
                            label: "Crime"
                        )
                        
                        ToggleButton(
                            isOn: $showCrimeNews,
                            icon: "newspaper.fill",
                            label: "News"
                        )
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(AppTheme.darkGray.opacity(0.9))
                    .cornerRadius(15)
                }
                .padding()
                .background(Color.black.opacity(0.2))
                
                Spacer()
                
                // SOS Button
                Button(action: handleSOS) {
                    Text("SOS")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            print("🔄 SafetyMapView appeared")
            initializeServices()
        }
        .onChange(of: selectedCity) { oldValue, newValue in
            updateMapForCity(newValue)
        }
        .alert("Emergency SOS", isPresented: $showingSosAlert) {
            Button("Send SOS to All Contacts", role: .destructive) {
                sendSOSToContacts()
            }
            Button("Call Police (100)", role: .destructive) {
                if let url = URL(string: "tel://100") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                Text("Location access is not granted. SOS messages will use approximate location. Consider enabling location access in Settings for more accurate location sharing.")
            } else {
                Text("Choose an emergency action")
            }
        }
        .sheet(isPresented: $showingEmergencyContacts) {
            EmergencyContactsView(emergencyNumbers: emergencyNumbers)
        }
        
        // Update map region when news items change
        .onChange(of: newsDataService.crimeNews) { oldValue, newValue in
            if !newValue.isEmpty {
                updateMapRegionForNews(newValue)
            }
        }
    }
    
    private func updateMapRegionForNews(_ news: [NewsItem]) {
        // Calculate the bounding box for all news items
        var minLat = news[0].coordinates.latitude
        var maxLat = news[0].coordinates.latitude
        var minLon = news[0].coordinates.longitude
        var maxLon = news[0].coordinates.longitude
        
        for item in news {
            minLat = min(minLat, item.coordinates.latitude)
            maxLat = max(maxLat, item.coordinates.latitude)
            minLon = min(minLon, item.coordinates.longitude)
            maxLon = max(maxLon, item.coordinates.longitude)
        }
        
        // Add some padding
        let padding = 0.1
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat + padding, 0.1),
            longitudeDelta: max(maxLon - minLon + padding, 0.1)
        )
        
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
    
    private func updateMapForCity(_ city: String) {
        if let coordinates = cityCoordinates[city] {
            print("🗺️ Updating map to city: \(city) at coordinates: \(coordinates.latitude), \(coordinates.longitude)")
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                ))
            }
        }
    }
    
    private let cityCoordinates: [String: CLLocationCoordinate2D] = [
        "Bangalore": CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        "Delhi": CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),
        "Mumbai": CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777),
        "Chennai": CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707),
        "Kolkata": CLLocationCoordinate2D(latitude: 22.5726, longitude: 88.3639)
    ]
}

struct ToggleButton: View {
    @Binding var isOn: Bool
    let icon: String
    let label: String
    
    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 10))
            }
            .foregroundColor(isOn ? .white : .gray)
            .frame(width: 50, height: 50)
            .background(isOn ? AppTheme.primaryPurple : AppTheme.darkGray)
            .cornerRadius(10)
        }
    }
}

#Preview {
    SafetyMapView()
} 