import SwiftUI
import MapKit
import CoreLocation

struct LocationDecodeView: View {
    @State private var locationCode = ""
    @State private var decodedLocation: CLLocationCoordinate2D?
    @State private var showingMap = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.nightBlack.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Decode Location Code")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    TextField("Enter Location Code", text: $locationCode)
                        .textFieldStyle(CustomTextFieldStyle())
                        .padding()
                    
                    Button(action: decodeLocation) {
                        Text("Decode Location")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.primaryPurple)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    if let location = decodedLocation {
                        VStack {
                            Text("Location Found")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("Lat: \(location.latitude, specifier: "%.4f")")
                                .foregroundColor(.white)
                            Text("Long: \(location.longitude, specifier: "%.4f")")
                                .foregroundColor(.white)
                            
                            Button(action: { showingMap = true }) {
                                Text("View on Map")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding()
                            
                            Button(action: openInMaps) {
                                Text("Open in Maps")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(AppTheme.darkGray)
                        .cornerRadius(15)
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .sheet(isPresented: $showingMap) {
                if let location = decodedLocation {
                    LocationMapView(coordinate: location)
                }
            }
            .navigationTitle("Location Decoder")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func decodeLocation() {
        if let location = EmergencyContact.decodeLocation(from: locationCode) {
            decodedLocation = location
            errorMessage = nil
        } else {
            errorMessage = "Invalid location code. Please check and try again."
            decodedLocation = nil
        }
    }
    
    private func openInMaps() {
        guard let location = decodedLocation else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location))
        mapItem.name = "Emergency Location"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct LocationMapView: View {
    let coordinate: CLLocationCoordinate2D
    @State private var region: MKCoordinateRegion
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        Map(position: .constant(.region(region))) {
            Annotation("Emergency Location", coordinate: coordinate) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
            }
        }
        .mapStyle(.standard)
    }
}

#Preview {
    LocationDecodeView()
} 