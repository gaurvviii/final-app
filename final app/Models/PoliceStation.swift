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

// Delhi Police Stations data (hardcoded)
let delhiPoliceStations = [
    PoliceStation(
        name: "PS Civil Lines",
        phoneNumber: "011-23979214",
        coordinate: CLLocationCoordinate2D(latitude: 28.6890036, longitude: 77.2217181),
        address: "Civil Lines, North District, Delhi"
    ),
    PoliceStation(
        name: "PS Timar Pur",
        phoneNumber: "011-23972222",
        coordinate: CLLocationCoordinate2D(latitude: 28.7065559, longitude: 77.2241975),
        address: "Timar Pur, North District, Delhi"
    ),
    PoliceStation(
        name: "PS Roop Nagar",
        phoneNumber: "011-23974444",
        coordinate: CLLocationCoordinate2D(latitude: 28.6848582, longitude: 77.2025435),
        address: "Roop Nagar, North District, Delhi"
    ),
    PoliceStation(
        name: "PS Sarai Rohilla",
        phoneNumber: "011-23352333",
        coordinate: CLLocationCoordinate2D(latitude: 28.6688069, longitude: 77.1834338),
        address: "Sarai Rohilla, North District, Delhi"
    ),
    PoliceStation(
        name: "PS Bara Hindu Rao",
        phoneNumber: "011-23918180",
        coordinate: CLLocationCoordinate2D(latitude: 28.6656794, longitude: 77.2081428),
        address: "Bara Hindu Rao, North District, Delhi"
    ),
    PoliceStation(
        name: "PS Chandni Chowk",
        phoneNumber: "011-23273001",
        coordinate: CLLocationCoordinate2D(latitude: 28.6506, longitude: 77.2334),
        address: "Chandni Chowk, Central District, Delhi"
    ),
    PoliceStation(
        name: "PS Karol Bagh",
        phoneNumber: "011-25783661",
        coordinate: CLLocationCoordinate2D(latitude: 28.6519, longitude: 77.1909),
        address: "Karol Bagh, Central District, Delhi"
    ),
    PoliceStation(
        name: "PS Connaught Place",
        phoneNumber: "011-23361235",
        coordinate: CLLocationCoordinate2D(latitude: 28.6315, longitude: 77.2167),
        address: "Connaught Place, New Delhi District, Delhi"
    ),
    PoliceStation(
        name: "PS Paharganj",
        phoneNumber: "011-23583333",
        coordinate: CLLocationCoordinate2D(latitude: 28.6448, longitude: 77.2167),
        address: "Paharganj, New Delhi District, Delhi"
    ),
    PoliceStation(
        name: "PS IP Estate",
        phoneNumber: "011-22211234",
        coordinate: CLLocationCoordinate2D(latitude: 28.6305, longitude: 77.2414),
        address: "IP Estate, Shahdara District, Delhi"
    ),
    PoliceStation(
        name: "PS Lajpat Nagar",
        phoneNumber: "011-24692222",
        coordinate: CLLocationCoordinate2D(latitude: 28.5677, longitude: 77.2437),
        address: "Lajpat Nagar, South District, Delhi"
    ),
    PoliceStation(
        name: "PS Greater Kailash",
        phoneNumber: "011-26429009",
        coordinate: CLLocationCoordinate2D(latitude: 28.5418, longitude: 77.2384),
        address: "Greater Kailash, South District, Delhi"
    ),
    PoliceStation(
        name: "PS Saket",
        phoneNumber: "011-26964040",
        coordinate: CLLocationCoordinate2D(latitude: 28.5206, longitude: 77.2013),
        address: "Saket, South District, Delhi"
    ),
    PoliceStation(
        name: "PS Dwarka",
        phoneNumber: "011-25398282",
        coordinate: CLLocationCoordinate2D(latitude: 28.6156, longitude: 77.0219),
        address: "Dwarka, South West District, Delhi"
    ),
    PoliceStation(
        name: "PS Vasant Kunj",
        phoneNumber: "011-26894300",
        coordinate: CLLocationCoordinate2D(latitude: 28.5244, longitude: 77.1593),
        address: "Vasant Kunj, South West District, Delhi"
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
        
        // Load both Bangalore and Delhi data
        policeStations = bangalorePoliceStations + delhiPoliceStations
        isLoading = false
    }
    
    func getPoliceStations(for city: String) -> [PoliceStation] {
        switch city.lowercased() {
        case "bangalore", "bengaluru":
            return bangalorePoliceStations
        case "delhi":
            return delhiPoliceStations
        default:
            return policeStations
        }
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