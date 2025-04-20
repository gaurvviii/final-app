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
    
    func loadPoliceStations() {
        isLoading = true
        errorMessage = nil
        
        // Read the CSV file
        if let path = Bundle.main.path(forResource: "police_data", ofType: "csv"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            let rows = content.components(separatedBy: .newlines)
            
            // Skip header row
            let dataRows = rows.dropFirst()
            
            policeStations = dataRows.compactMap { row in
                let columns = row.components(separatedBy: ",")
                guard columns.count >= 6 else { return nil }
                
                let name = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let address = name // Using name as address for now
                
                return PoliceStation(
                    name: name,
                    phoneNumber: PoliceStation.extractPhoneNumber(from: address),
                    coordinate: PoliceStation.extractCoordinates(from: address),
                    address: PoliceStation.cleanAddress(address)
                )
            }
        } else {
            errorMessage = "Failed to load police station data"
        }
        
        isLoading = false
    }
    
    func getNearbyPoliceStations(to location: CLLocation, radiusInMeters: Double = 5000) -> [PoliceStation] {
        var nearbyStations: [PoliceStation] = []
        
        for station in policeStations {
            let stationLocation = CLLocation(
                latitude: station.coordinate.latitude,
                longitude: station.coordinate.longitude
            )
            
            let distance = location.distance(from: stationLocation)
            if distance <= radiusInMeters {
                var updatedStation = station
                updatedStation.distance = distance
                nearbyStations.append(updatedStation)
            }
        }
        
        // Sort by distance using explicit closure
        return nearbyStations.sorted { (station1: PoliceStation, station2: PoliceStation) -> Bool in
            return station1.distance < station2.distance
        }
    }
} 