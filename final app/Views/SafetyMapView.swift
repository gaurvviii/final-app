import SwiftUI
import MapKit

struct SafetyMapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var crimeDataService = CrimeDataService()
    @StateObject private var newsDataService = NewsDataService()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946), // Bangalore
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedPlace: SafePlace?
    @State private var selectedPoliceStation: PoliceStation?
    @State private var selectedCrimeHotspot: CrimeHotspot?
    @State private var selectedCrimeNews: CrimeNews?
    @State private var showingDirections = false
    @State private var showPoliceStations = true
    @State private var showCrimeHotspots = true
    @State private var showCrimeNews = true
    @State private var isNightMode = false
    @State private var selectedCity = "Bangalore"
    @State private var filterTimeOfDay: TimePattern?
    @State private var camera: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    @State private var selectedDangerZone: DangerZone?
    @State private var showingDangerZoneDetail = false
    
    private let availableCities = ["Bangalore", "Delhi", "Mumbai", "Chennai", "Kolkata"]
    
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
        return nearestPoliceStations(to: location)
    }
    
    // Nearby crime hotspots based on user location and filters
    private var nearbyCrimeHotspots: [CrimeHotspot] {
        guard let location = locationManager.location else { return [] }
        
        var hotspots = crimeDataService.getNearbyHotspots(to: location)
        
        // Filter by city
        hotspots = hotspots.filter { $0.city == selectedCity }
        
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
                            coordinate: station.coordinates
                        )
                        .tint(.blue)
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
                
                // Safe Zones
                ForEach(newsDataService.safeZones) { zone in
                    MapCircle(
                        center: zone.coordinate,
                        radius: 500 // 500 meters radius
                    )
                    .foregroundStyle(.green.opacity(0.2))
                    .stroke(.green, lineWidth: 2)
                }
                
                // Danger Zones
                if showCrimeHotspots {
                    ForEach(nearbyCrimeHotspots) { hotspot in
                        MapCircle(
                            center: hotspot.coordinate,
                            radius: Double(getDangerRadius(for: hotspot))
                        )
                        .foregroundStyle(.red.opacity(0.2))
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
            
            // Navigation Overlay
            VStack {
                // Top Bar
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
                        
                        Toggle("Show Police Stations", isOn: $showPoliceStations)
                        Toggle("Show Crime Hotspots", isOn: $showCrimeHotspots)
                        Toggle("Show Recent Crime News", isOn: $showCrimeNews)
                        Toggle("Night Mode", isOn: $isNightMode)
                        
                        Button("Test API Connection") {
                            newsDataService.testAPI()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(AppTheme.darkGray)
                            .clipShape(Circle())
                    }
                    
                    if let station = selectedPoliceStation {
                        SafetyLocationBadge(title: station.name, subtitle: "Police Station")
                    } else if let hotspot = selectedCrimeHotspot {
                        CrimeHotspotBadge(hotspot: hotspot)
                    } else if let news = selectedCrimeNews {
                        CrimeNewsBadge(news: news)
                    } else if let place = selectedPlace {
                        SafetyLocationBadge(title: place.name, subtitle: "Safe Zone")
                    } else {
                        Text(selectedCity)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(AppTheme.darkGray.opacity(0.8))
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Safety Status
                if let hotspot = selectedCrimeHotspot {
                    CrimeHotspotDetailCard(hotspot: hotspot) {
                        if let location = locationManager.location {
                            let nearestStation = nearestPoliceStations(
                                to: CLLocation(
                                    latitude: hotspot.coordinate.latitude,
                                    longitude: hotspot.coordinate.longitude
                                ),
                                limit: 1
                            ).first
                            selectedPoliceStation = nearestStation
                            selectedCrimeHotspot = nil
                        }
                    }
                } else if let station = selectedPoliceStation {
                    PoliceStationDetailCard(station: station)
                } else if let news = selectedCrimeNews {
                    CrimeNewsDetailCard(news: news)
                } else if showingDirections {
                    NavigationInstructionView()
                }
                
                // Bottom Controls
                HStack(spacing: 15) {
                    Button(action: { 
                        if let location = locationManager.location {
                            region.center = location.coordinate
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(AppTheme.darkGray)
                            .clipShape(Circle())
                    }
                    
                    if selectedPoliceStation != nil || selectedPlace != nil {
                        Button(action: { showingDirections.toggle() }) {
                            HStack {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                Text("Navigate")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(AppTheme.primaryPurple)
                            .cornerRadius(25)
                        }
                    }
                    
                    if showCrimeHotspots && !nearbyCrimeHotspots.isEmpty {
                        DangerLevelIndicator(isInDangerZone: !nearbyCrimeHotspots.isEmpty)
                    }
                }
                .padding()
                
                // Safety Legend
                HStack(spacing: 20) {
                    HStack {
                        Circle()
                            .fill(Color.red.opacity(0.3))
                            .frame(width: 20, height: 20)
                        Text("Danger Zone")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 20, height: 20)
                        Text("Safe Zone")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            }
        }
        .preferredColorScheme(isNightMode ? .dark : .light)
        .onAppear {
            // Set initial camera position to Bangalore
            if let coordinates = cityCoordinates["Bangalore"] {
                camera = .region(MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                ))
            }
            crimeDataService.fetchCrimeData()
            newsDataService.fetchCrimeNews { _ in }
            newsDataService.testAPI()
        }
    }
}

struct CrimeHotspotBadge: View {
    let hotspot: CrimeHotspot
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(hotspot.color)
            
            VStack(alignment: .leading) {
                Text(hotspot.area)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                HStack {
                    Text(hotspot.riskLevel.rawValue)
                        .font(.caption)
                        .foregroundColor(hotspot.color)
                    
                    Text("•")
                    
                    Text("\(hotspot.crimeCount) incidents")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(AppTheme.darkGray.opacity(0.8))
        .cornerRadius(20)
    }
}

struct CrimeHotspotDetailCard: View {
    let hotspot: CrimeHotspot
    let onFindPoliceStation: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(hotspot.color)
                
                Text("High Risk Area")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(hotspot.riskLevel.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(hotspot.color.opacity(0.2))
                    .foregroundColor(hotspot.color)
                    .cornerRadius(10)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(hotspot.area)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(hotspot.crimeCount) incidents reported")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.yellow)
                    
                    Text(hotspot.timePattern.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                if !hotspot.crimeTypes.isEmpty {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.orange)
                        
                        Text(hotspot.crimeTypes.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: onFindPoliceStation) {
                        HStack {
                            Image(systemName: "building.columns.fill")
                            Text("Nearest Police Station")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(15)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct PoliceStationMarker: View {
    let station: PoliceStation
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "building.columns.fill")
                    .foregroundColor(isSelected ? AppTheme.primaryPurple : .blue)
                    .font(.system(size: isSelected ? 24 : 20))
                
                if isSelected {
                    Text(station.name)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.darkGray.opacity(0.8))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct SafetyLocationBadge: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(AppTheme.darkGray.opacity(0.8))
        .cornerRadius(20)
    }
}

struct PoliceStationDetailCard: View {
    let station: PoliceStation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.columns.fill")
                    .foregroundColor(.blue)
                
                Text("Police Station")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(formatDistance(station.distance))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(station.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(station.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                    
                    Text(station.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        guard let url = URL(string: "tel:\(station.phoneNumber.replacingOccurrences(of: "-", with: ""))") else { return }
                        UIApplication.shared.open(url)
                    }) {
                        Text("Call")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m away"
        } else {
            let km = meters / 1000
            return String(format: "%.1fkm away", km)
        }
    }
}

struct NavigationInstructionView: View {
    var body: some View {
        HStack {
            Image(systemName: "arrow.left")
                .font(.title2)
                .foregroundColor(.white)
            
            VStack(alignment: .leading) {
                Text("Turn left")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("123 m")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { /* Show on map */ }) {
                Image(systemName: "map.fill")
                    .foregroundColor(AppTheme.primaryPurple)
            }
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct DangerLevelIndicator: View {
    let isInDangerZone: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(isInDangerZone ? .red : .green)
            
            Text(isInDangerZone ? "Caution Area" : "Safe Area")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isInDangerZone ? Color.red.opacity(0.3) : Color.green.opacity(0.3))
        .cornerRadius(20)
    }
}

// New Crime News Badge
struct CrimeNewsBadge: View {
    let news: CrimeNews
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "newspaper.fill")
                .foregroundColor(.red)
            
            VStack(alignment: .leading) {
                Text(news.title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text(news.pubDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(AppTheme.darkGray.opacity(0.8))
        .cornerRadius(20)
    }
}

// New Crime News Detail Card
struct CrimeNewsDetailCard: View {
    let news: CrimeNews
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "newspaper.fill")
                    .foregroundColor(.red)
                
                Text("Recent Crime News")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(news.pubDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(news.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let description = news.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                if let content = news.content {
                    Text(content)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if let url = URL(string: news.link) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("Read More")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(15)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.darkGray)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

#Preview {
    SafetyMapView()
} 