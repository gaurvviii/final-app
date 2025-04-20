import SwiftUI
import MapKit

struct SafetyMapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var policeDataService = PoliceDataService()
    @StateObject private var metroDataService = MetroDataService()
    @StateObject private var crimeDataService = CrimeDataService()
    @StateObject private var newsDataService = NewsDataService()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946), // Bangalore
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedPlace: SafePlace?
    @State private var selectedPoliceStation: PoliceStation?
    @State private var selectedMetroStation: MetroStation?
    @State private var selectedCrimeHotspot: CrimeHotspot?
    @State private var selectedCrimeNews: CrimeNews?
    @State private var showingDirections = false
    @State private var showPoliceStations = true
    @State private var showMetroStations = true
    @State private var showCrimeHotspots = true
    @State private var showCrimeNews = true
    @State private var isNightMode = false
    @State private var selectedCity = "Bangalore"
    @State private var filterTimeOfDay: TimePattern?
    @State private var selectedYear: Int?
    @State private var camera: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    @State private var selectedDangerZone: DangerZone?
    @State private var showingDangerZoneDetail = false
    
    private let availableCities = ["Bangalore", "Delhi", "Mumbai", "Chennai", "Kolkata"]
    private let availableYears = Array(2001...2014)
    
    private let cityCoordinates: [String: CLLocationCoordinate2D] = [
        "Bangalore": CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        "Delhi": CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),
        "Mumbai": CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777),
        "Chennai": CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707),
        "Kolkata": CLLocationCoordinate2D(latitude: 22.5726, longitude: 88.3639)
    ]
    
    // Nearest police stations based on user location
    private var nearestStations: [PoliceStation] {
        guard let location = locationManager.location else { return [] }
        return policeDataService.getNearbyPoliceStations(to: location)
    }
    
    // Nearest metro stations based on user location
    private var nearestMetroStations: [MetroStation] {
        guard let location = locationManager.location else { return [] }
        return metroDataService.getNearbyMetroStations(to: location)
    }
    
    // Nearby crime hotspots based on user location and filters
    private var nearbyCrimeHotspots: [CrimeHotspot] {
        guard let location = locationManager.location else { return [] }
        
        var hotspots = crimeDataService.getHotspots(for: selectedCity)
        
        // Filter by time of day if selected
        if let timeFilter = filterTimeOfDay {
            hotspots = hotspots.filter { $0.timePattern == timeFilter || $0.timePattern == .allDay }
        }
        
        return hotspots
    }
    
    private func getDangerColor(for hotspot: CrimeHotspot) -> Color {
        let opacity: Double
        switch hotspot.riskLevel {
        case .high:
            opacity = 0.4
        case .medium:
            opacity = 0.3
        case .low:
            opacity = 0.2
        }
        return Color.red.opacity(opacity)
    }
    
    private func getDangerRadius(for hotspot: CrimeHotspot) -> CGFloat {
        let baseRadius: CGFloat
        switch hotspot.riskLevel {
        case .high:
            baseRadius = 200
        case .medium:
            baseRadius = 150
        case .low:
            baseRadius = 100
        }
        
        // Scale by crime count for visual effect
        let countFactor = min(CGFloat(hotspot.crimeCount) / 100.0, 2.0)
        return baseRadius * (1 + countFactor * 0.5)
    }
    
    var body: some View {
        ZStack {
            Map(position: $camera) {
                // Police Station Markers
                if showPoliceStations {
                    ForEach(nearestStations) { station in
                        Marker(
                            "Police Station",
                            coordinate: station.coordinate
                        )
                        .tint(.blue)
                    }
                }
                
                // Metro Station Markers
                if showMetroStations {
                    ForEach(nearestMetroStations) { station in
                        Marker(
                            "Metro Station",
                            coordinate: station.coordinate
                        )
                        .tint(.purple)
                    }
                }
                
                // Crime Hotspots
                if showCrimeHotspots {
                    ForEach(nearbyCrimeHotspots) { hotspot in
                        Marker(
                            "Crime Hotspot",
                            coordinate: hotspot.coordinate
                        )
                        .tint(.red)
                    }
                }
                
                // Crime News Markers
                if showCrimeNews {
                    ForEach(newsDataService.crimeNews.filter { $0.coordinates != nil }) { news in
                        if let coordinates = news.coordinates {
                            Marker(
                                news.title,
                                coordinate: coordinates
                            )
                            .tint(.orange)
                        }
                    }
                }
                
                if let userLocation = locationManager.location {
                    UserAnnotation()
                }
                
                // Safe Zones around Police Stations
                ForEach(nearestStations) { station in
                    MapCircle(
                        center: station.coordinate,
                        radius: 1000 // 1km radius
                    )
                    .foregroundStyle(.green.opacity(0.2))
                    .stroke(.green, lineWidth: 2)
                }
                
                // Safe Zones around Metro Stations
                ForEach(nearestMetroStations) { station in
                    MapCircle(
                        center: station.coordinate,
                        radius: 500 // 500m radius
                    )
                    .foregroundStyle(.blue.opacity(0.2))
                    .stroke(.blue, lineWidth: 2)
                }
                
                // Danger Zones
                if showCrimeHotspots {
                    ForEach(nearbyCrimeHotspots) { hotspot in
                        MapCircle(
                            center: hotspot.coordinate,
                            radius: getDangerRadius(for: hotspot)
                        )
                        .foregroundStyle(getDangerColor(for: hotspot))
                        .stroke(.red, lineWidth: 2)
                    }
                }
            }
            .mapStyle(isNightMode ? .hybrid : .standard)
            .ignoresSafeArea()
            .onChange(of: selectedCity) { newCity in
                if let coordinates = cityCoordinates[newCity] {
                    withAnimation {
                        camera = .region(MKCoordinateRegion(
                            center: coordinates,
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        ))
                    }
                }
            }
            .onChange(of: showPoliceStations) { _ in
                if let location = locationManager.location {
                    region.center = location.coordinate
                }
            }
            .onChange(of: showMetroStations) { _ in
                if let location = locationManager.location {
                    region.center = location.coordinate
                }
            }
            .onChange(of: showCrimeHotspots) { _ in
                if let location = locationManager.location {
                    region.center = location.coordinate
                }
            }
            .onChange(of: showCrimeNews) { _ in
                newsDataService.fetchCrimeNews { _ in }
            }
            .onChange(of: selectedYear) { _ in
                // Refresh crime hotspots when year changes
            }
            
            // Navigation Overlay
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Menu {
                        Picker("City", selection: $selectedCity) {
                            ForEach(availableCities, id: \.self) { city in
                                Text(city).tag(city)
                            }
                        }
                        
                        Picker("Year", selection: $selectedYear) {
                            Text("All Years").tag(nil as Int?)
                            ForEach(availableYears, id: \.self) { year in
                                Text("\(year)").tag(year as Int?)
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
                .padding()
                
                Spacer()
                
                // Bottom Controls
                HStack {
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
                .padding()
                .background(AppTheme.darkGray.opacity(0.9))
                .cornerRadius(15)
                .padding()
            }
        }
    }
}

struct ToggleButton: View {
    @Binding var isOn: Bool
    let icon: String
    let label: String
    
    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(isOn ? .white : .gray)
            .padding()
            .background(isOn ? AppTheme.primaryPurple : AppTheme.darkGray)
            .cornerRadius(10)
        }
    }
}

#Preview {
    SafetyMapView()
} 