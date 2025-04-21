import Foundation
import MapKit

struct PoliceStation: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    var distance: Double = 0.0  // Added distance property
    
    // Helper function to extract coordinates from address
    static func extractCoordinates(from address: String) -> CLLocationCoordinate2D {
        // This is a placeholder - in a real app, you would use geocoding
        // For now, we'll use some default coordinates for Bangalore
        return CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
    }
    
    // Helper function to extract phone number from address
    static func extractPhoneNumber(from address: String) -> String {
        let pattern = "Ph no\\.\\s*([\\d-]+)"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: address, range: NSRange(address.startIndex..., in: address)),
           let range = Range(match.range(at: 1), in: address) {
            return String(address[range])
        }
        return ""
    }
    
    // Helper function to clean address
    static func cleanAddress(_ address: String) -> String {
        return address.replacingOccurrences(of: "Ph no\\..*$", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Bangalore Women's Police Stations data
let bangalorePoliceStations = [
    PoliceStation(
        name: "Women's Police Station, Cubbon Park",
        phoneNumber: "080-2294-2222",
        coordinate: CLLocationCoordinate2D(latitude: 12.9766, longitude: 77.5713),
        address: "Cubbon Park, Bengaluru"
    ),
    PoliceStation(
        name: "Women's Police Station, Koramangala",
        phoneNumber: "080-2573-1000",
        coordinate: CLLocationCoordinate2D(latitude: 12.9352, longitude: 77.6245),
        address: "Koramangala, Bengaluru"
    ),
    PoliceStation(
        name: "Women's Police Station, Whitefield",
        phoneNumber: "080-2841-1000",
        coordinate: CLLocationCoordinate2D(latitude: 12.9698, longitude: 77.7499),
        address: "Whitefield, Bengaluru"
    ),
    PoliceStation(
        name: "Women's Police Station, Malleswaram",
        phoneNumber: "080-2334-1000",
        coordinate: CLLocationCoordinate2D(latitude: 13.0067, longitude: 77.5751),
        address: "Malleswaram, Bengaluru"
    ),
    PoliceStation(
        name: "Women's Police Station, Jayanagar",
        phoneNumber: "080-2663-1000",
        coordinate: CLLocationCoordinate2D(latitude: 12.9304, longitude: 77.5834),
        address: "Jayanagar, Bengaluru"
    )
]

// Data service to load and manage police station data
class PoliceDataService: ObservableObject {
    @Published var policeStations: [PoliceStation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadPoliceStations()
    }
    
    func loadPoliceStations() {
        isLoading = true
        errorMessage = nil
        
        // Use local data
        policeStations = bangalorePoliceStations
        isLoading = false
    }
    
    func getNearbyPoliceStations(to location: CLLocation) -> [PoliceStation] {
        return policeStations.map { station in
            var updatedStation = station
            let stationLocation = CLLocation(
                latitude: station.coordinate.latitude,
                longitude: station.coordinate.longitude
            )
            updatedStation.distance = location.distance(from: stationLocation)
            return updatedStation
        }.sorted { $0.distance < $1.distance }
    }
} 