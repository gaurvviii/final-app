import SwiftUI
import MapKit

struct SafetyMapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var crimeDataService = CrimeDataService()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946), // Bangalore
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedPlace: SafePlace?
    @State private var selectedPoliceStation: PoliceStation?
    @State private var selectedCrimeHotspot: CrimeHotspot?
    @State private var showingDirections = false
    @State private var showPoliceStations = true
    @State private var showCrimeHotspots = true
    @State private var isNightMode = false
    @State private var selectedCity = "Bangalore"
    @State private var filterTimeOfDay: TimePattern?
    
    private let availableCities = ["Bangalore", "Delhi", "Mumbai", "Chennai", "Kolkata"]
    
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
    
    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow),
                annotationItems: showPoliceStations ? nearestStations : []) { station in
                MapAnnotation(coordinate: station.coordinates) {
                    PoliceStationMarker(station: station, isSelected: selectedPoliceStation?.id == station.id) {
                        selectedPoliceStation = station
                        selectedCrimeHotspot = nil
                        selectedPlace = nil
                    }
                }
            }
            .overlay(
                showCrimeHotspots ?
                CrimeHotspotsOverlay(
                    hotspots: nearbyCrimeHotspots,
                    onSelect: { hotspot in
                        selectedCrimeHotspot = hotspot
                        selectedPoliceStation = nil
                        selectedPlace = nil
                    },
                    selectedHotspotID: selectedCrimeHotspot?.id
                ) : nil
            )
            .ignoresSafeArea()
            
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
                        Toggle("Night Mode", isOn: $isNightMode)
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
            }
        }
        .preferredColorScheme(isNightMode ? .dark : .light)
        .onAppear {
            crimeDataService.fetchCrimeData()
        }
    }
}

struct CrimeHotspotsOverlay: View {
    let hotspots: [CrimeHotspot]
    let onSelect: (CrimeHotspot) -> Void
    let selectedHotspotID: UUID?
    
    var body: some View {
        ZStack {
            ForEach(hotspots) { hotspot in
                Circle()
                    .fill(hotspot.color.opacity(0.2))
                    .frame(width: getCrimeRadius(for: hotspot))
                    .position(
                        x: hotspot.coordinate.longitude,
                        y: hotspot.coordinate.latitude
                    )
                
                Button(action: { onSelect(hotspot) }) {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(hotspot.color)
                            .font(.system(size: selectedHotspotID == hotspot.id ? 30 : 24))
                            .shadow(color: .black, radius: 2)
                        
                        if selectedHotspotID == hotspot.id {
                            Text("\(hotspot.crimeCount)")
                                .font(.caption)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .position(
                    x: hotspot.coordinate.longitude,
                    y: hotspot.coordinate.latitude
                )
            }
        }
    }
    
    private func getCrimeRadius(for hotspot: CrimeHotspot) -> CGFloat {
        let baseRadius: CGFloat
        switch hotspot.riskLevel {
        case .high:
            baseRadius = 120
        case .medium:
            baseRadius = 100
        case .low:
            baseRadius = 80
        }
        
        // Scale by crime count for visual effect
        let countFactor = min(CGFloat(hotspot.crimeCount) / 100.0, 2.0)
        return baseRadius * (1 + countFactor * 0.5)
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

#Preview {
    SafetyMapView()
} 