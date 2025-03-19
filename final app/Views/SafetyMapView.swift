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
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow),
                annotationItems: safePlaces) { place in
                MapAnnotation(coordinate: place.coordinate) {
                    VStack {
                        Image(systemName: "shield.fill")
                            .foregroundColor(AppTheme.primaryPurple)
                            .font(.title)
                        
                        Text(place.name)
                            .font(.caption)
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(5)
                    }
                    .onTapGesture {
                        selectedPlace = place
                    }
                }
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Safety Zone Controls
                VStack(spacing: 0) {
                    if let selected = selectedPlace {
                        SafePlaceDetailView(place: selected) {
                            selectedPlace = nil
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            if let location = locationManager.location {
                                region.center = location.coordinate
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Spacer()
                        
                        Toggle("Safety Zones", isOn: $showingSafetyZones)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                    .padding()
                }
            }
        }
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