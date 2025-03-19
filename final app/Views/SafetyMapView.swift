import SwiftUI
import MapKit

struct SafetyMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946), // Bangalore
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedPlace: SafePlace?
    @State private var selectedPoliceStation: PoliceStation?
    @State private var selectedUnsafeArea: UnsafeArea?
    @State private var showingDirections = false
    @State private var showPoliceStations = true
    @State private var showUnsafeAreas = true
    @State private var isNightMode = false
    
    // Nearest police stations based on user location
    private var nearestStations: [PoliceStation] {
        guard let location = locationManager.location else { return [] }
        return nearestPoliceStations(to: location)
    }
    
    // Nearby unsafe areas based on user location
    private var nearbyDangerZones: [UnsafeArea] {
        guard let location = locationManager.location else { return [] }
        return nearbyUnsafeAreas(to: location)
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
                        selectedUnsafeArea = nil
                        selectedPlace = nil
                    }
                }
            }
            .overlay(
                showUnsafeAreas ?
                UnsafeAreasOverlay(unsafeAreas: nearbyDangerZones, onSelect: { area in
                    selectedUnsafeArea = area
                    selectedPoliceStation = nil
                    selectedPlace = nil
                }, selectedAreaID: selectedUnsafeArea?.id)
                : nil
            )
            .ignoresSafeArea()
            
            // Navigation Overlay
            VStack {
                // Top Bar
                HStack {
                    Menu {
                        Toggle("Show Police Stations", isOn: $showPoliceStations)
                        Toggle("Show Unsafe Areas", isOn: $showUnsafeAreas)
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
                    } else if let area = selectedUnsafeArea {
                        UnsafeAreaBadge(area: area)
                    } else if let place = selectedPlace {
                        SafetyLocationBadge(title: place.name, subtitle: "Safe Zone")
                    }
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Safety Status
                if let area = selectedUnsafeArea {
                    UnsafeAreaDetailCard(area: area)
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
                    
                    if showUnsafeAreas && !nearbyDangerZones.isEmpty {
                        DangerLevelIndicator(isInDangerZone: !nearbyDangerZones.isEmpty)
                    }
                }
                .padding()
            }
        }
        .preferredColorScheme(isNightMode ? .dark : .light)
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

struct UnsafeAreasOverlay: View {
    let unsafeAreas: [UnsafeArea]
    let onSelect: (UnsafeArea) -> Void
    let selectedAreaID: UUID?
    
    var body: some View {
        ZStack {
            ForEach(unsafeAreas) { area in
                Circle()
                    .fill(area.color.opacity(0.2))
                    .frame(width: getRiskRadius(for: area.riskLevel))
                    .position(
                        x: area.coordinates.longitude,
                        y: area.coordinates.latitude
                    )
                
                Button(action: { onSelect(area) }) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(area.color)
                        .font(.system(size: selectedAreaID == area.id ? 30 : 24))
                        .shadow(color: .black, radius: 2)
                }
                .position(
                    x: area.coordinates.longitude,
                    y: area.coordinates.latitude
                )
            }
        }
    }
    
    private func getRiskRadius(for riskLevel: RiskLevel) -> CGFloat {
        switch riskLevel {
        case .high:
            return 120
        case .medium:
            return 100
        case .low:
            return 80
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

struct UnsafeAreaBadge: View {
    let area: UnsafeArea
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(area.color)
            
            VStack(alignment: .leading) {
                Text(area.name)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text(area.riskLevel.rawValue)
                    .font(.caption)
                    .foregroundColor(area.color)
            }
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

struct UnsafeAreaDetailCard: View {
    let area: UnsafeArea
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(area.color)
                
                Text("Unsafe Area")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(area.riskLevel.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(area.color.opacity(0.2))
                    .foregroundColor(area.color)
                    .cornerRadius(10)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(area.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(area.crimeDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.yellow)
                    
                    Text(area.timeOfDay.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        // Find nearest police station
                    }) {
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