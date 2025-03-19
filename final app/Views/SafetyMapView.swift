import SwiftUI
import MapKit

struct SafetyMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3361, longitude: -122.0363),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var showingSafetyZones = true
    @State private var selectedPlace: SafePlace?
    @State private var showingDirections = false
    
    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow),
                annotationItems: safePlaces) { place in
                MapAnnotation(coordinate: place.coordinate) {
                    SafetyMarker(place: place, isSelected: selectedPlace?.id == place.id) {
                        selectedPlace = place
                    }
                }
            }
            .ignoresSafeArea()
            
            // Navigation Overlay
            VStack {
                // Top Bar
                HStack {
                    Button(action: { /* Close action */ }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(AppTheme.darkGray)
                            .clipShape(Circle())
                    }
                    
                    if let place = selectedPlace {
                        Text(place.name)
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
                
                // Navigation Instructions
                if showingDirections {
                    NavigationInstructionView()
                }
                
                // Bottom Controls
                HStack(spacing: 15) {
                    Button(action: { /* Center on user */ }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(AppTheme.darkGray)
                            .clipShape(Circle())
                    }
                    
                    if selectedPlace != nil {
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
                }
                .padding()
            }
        }
    }
}

struct SafetyMarker: View {
    let place: SafePlace
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "shield.fill")
                    .foregroundColor(isSelected ? AppTheme.primaryPurple : .white)
                    .font(.system(size: isSelected ? 24 : 20))
                
                if isSelected {
                    Text(place.name)
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

struct SafePlace: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let type: SafePlaceType
    let address: String
    let phone: String
}

enum SafePlaceType {
    case police
    case hospital
    case safeZone
}

struct SafePlaceDetailView: View {
    let place: SafePlace
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(place.name)
                    .font(.headline)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            Text(place.address)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "phone.fill")
                Text(place.phone)
            }
            .foregroundColor(AppTheme.deepBlue)
            
            Button(action: {
                // Open in Maps
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
                mapItem.name = place.name
                mapItem.openInMaps(launchOptions: nil)
            }) {
                Text("Get Directions")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primaryPurple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}

// Sample Data
let safePlaces = [
    SafePlace(
        name: "Central Police Station",
        coordinate: CLLocationCoordinate2D(latitude: 37.3361, longitude: -122.0363),
        type: .police,
        address: "123 Safety Street",
        phone: "911"
    ),
    SafePlace(
        name: "City Hospital",
        coordinate: CLLocationCoordinate2D(latitude: 37.3371, longitude: -122.0373),
        type: .hospital,
        address: "456 Health Avenue",
        phone: "408-555-0123"
    ),
    SafePlace(
        name: "Community Safe Zone",
        coordinate: CLLocationCoordinate2D(latitude: 37.3351, longitude: -122.0353),
        type: .safeZone,
        address: "789 Community Blvd",
        phone: "408-555-0456"
    )
]

#Preview {
    SafetyMapView()
} 