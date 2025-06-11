import Foundation
import MapKit
import Combine
import SwiftUI

class CrimeDataService: ObservableObject {
    @Published var crimeHotspots: [CrimeHotspot] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadLocalCrimeData()
    }
    
    func fetchCrimeData() {
        isLoading = true
        errorMessage = nil
        
        // Use local data for now
        loadLocalCrimeData()
        isLoading = false
    }
    
    // Load local crime data based on the police and crime CSV data
    private func loadLocalCrimeData() {
        // Bangalore hotspots based on police data
        let bangaloreHotspots = [
            CrimeHotspot(
                id: UUID(),
                city: "Bangalore",
                area: "Majestic Area",
                coordinate: CLLocationCoordinate2D(latitude: 12.9766, longitude: 77.5713),
                crimeCount: 187,
                crimeTypes: ["Harassment", "Theft", "Stalking"],
                riskLevel: .high,
                timePattern: .night
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Bangalore",
                area: "K.R. Market",
                coordinate: CLLocationCoordinate2D(latitude: 12.9688, longitude: 77.5764),
                crimeCount: 154,
                crimeTypes: ["Harassment", "Theft"],
                riskLevel: .medium,
                timePattern: .allDay
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Bangalore",
                area: "Shivajinagar",
                coordinate: CLLocationCoordinate2D(latitude: 12.9850, longitude: 77.6011),
                crimeCount: 129,
                crimeTypes: ["Theft", "Harassment"],
                riskLevel: .medium,
                timePattern: .evening
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Bangalore",
                area: "Marathahalli",
                coordinate: CLLocationCoordinate2D(latitude: 12.9591, longitude: 77.6974),
                crimeCount: 112,
                crimeTypes: ["Stalking", "Harassment"],
                riskLevel: .medium,
                timePattern: .night
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Bangalore",
                area: "Peenya Industrial Area",
                coordinate: CLLocationCoordinate2D(latitude: 13.0302, longitude: 77.5192),
                crimeCount: 132,
                crimeTypes: ["Assault", "Harassment"],
                riskLevel: .high,
                timePattern: .night
            )
        ]
        
        // Delhi hotspots based on known high-crime areas
        let delhiHotspots = [
            CrimeHotspot(
                id: UUID(),
                city: "Delhi",
                area: "Paharganj",
                coordinate: CLLocationCoordinate2D(latitude: 28.6448, longitude: 77.2167),
                crimeCount: 234,
                crimeTypes: ["Harassment", "Theft", "Stalking"],
                riskLevel: .high,
                timePattern: .night
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Delhi",
                area: "Chandni Chowk",
                coordinate: CLLocationCoordinate2D(latitude: 28.6506, longitude: 77.2334),
                crimeCount: 189,
                crimeTypes: ["Harassment", "Theft"],
                riskLevel: .high,
                timePattern: .allDay
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Delhi",
                area: "Karol Bagh",
                coordinate: CLLocationCoordinate2D(latitude: 28.6519, longitude: 77.1909),
                crimeCount: 156,
                crimeTypes: ["Stalking", "Harassment"],
                riskLevel: .medium,
                timePattern: .evening
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Delhi",
                area: "Connaught Place",
                coordinate: CLLocationCoordinate2D(latitude: 28.6315, longitude: 77.2167),
                crimeCount: 143,
                crimeTypes: ["Harassment", "Theft"],
                riskLevel: .medium,
                timePattern: .evening
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Delhi",
                area: "Nizamuddin",
                coordinate: CLLocationCoordinate2D(latitude: 28.5933, longitude: 77.2507),
                crimeCount: 167,
                crimeTypes: ["Assault", "Harassment"],
                riskLevel: .high,
                timePattern: .night
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Delhi",
                area: "Lajpat Nagar",
                coordinate: CLLocationCoordinate2D(latitude: 28.5677, longitude: 77.2437),
                crimeCount: 134,
                crimeTypes: ["Theft", "Harassment"],
                riskLevel: .medium,
                timePattern: .day
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Delhi",
                area: "Sarai Kale Khan",
                coordinate: CLLocationCoordinate2D(latitude: 28.5933, longitude: 77.2507),
                crimeCount: 178,
                crimeTypes: ["Harassment", "Stalking"],
                riskLevel: .high,
                timePattern: .allDay
            )
        ]
        
        self.crimeHotspots = bangaloreHotspots + delhiHotspots
    }
    
    // Get crime hotspots for a specific city
    func getHotspots(for city: String? = nil) -> [CrimeHotspot] {
        if let city = city {
            return crimeHotspots.filter { $0.city.lowercased() == city.lowercased() }
        }
        return crimeHotspots
    }
    
    // Find crime hotspots near a specific location
    func getNearbyHotspots(to location: CLLocation, radiusInMeters: Double = 5000) -> [CrimeHotspot] {
        var nearbyHotspots: [CrimeHotspot] = []
        
        for hotspot in crimeHotspots {
            let hotspotLocation = CLLocation(
                latitude: hotspot.coordinate.latitude,
                longitude: hotspot.coordinate.longitude
            )
            
            let distance = location.distance(from: hotspotLocation)
            if distance <= radiusInMeters {
                var updatedHotspot = hotspot
                updatedHotspot.distance = distance
                nearbyHotspots.append(updatedHotspot)
            }
        }
        
        // Sort by distance
        return nearbyHotspots.sorted { $0.distance ?? 0 < $1.distance ?? 0 }
    }
}

// Data models for crime data
struct CrimeDataResponse: Codable {
    let records: [Record]
    
    struct Record: Codable {
        // Define based on actual API response structure
        // This is a placeholder
        let state: String
        let district: String
        let year: String
        let crimeHead: String
        let cases: Int
    }
}

struct CrimeHotspot: Identifiable {
    let id: UUID
    let city: String
    let area: String
    let coordinate: CLLocationCoordinate2D
    let crimeCount: Int
    let crimeTypes: [String]
    let riskLevel: RiskLevel
    let timePattern: TimePattern
    var distance: Double? = nil
    
    var color: Color {
        switch riskLevel {
        case .high: return .red
        case .medium: return .orange
        case .low: return .yellow
        }
    }
    
    var radiusInMeters: Double {
        switch riskLevel {
        case .high: return 300
        case .medium: return 250
        case .low: return 200
        }
    }
}

enum RiskLevel: String, Codable {
    case high = "High Risk"
    case medium = "Medium Risk"
    case low = "Low Risk"
}

enum TimePattern: String, Codable {
    case night = "Night (9PM - 5AM)"
    case evening = "Evening (5PM - 9PM)"
    case day = "Day (5AM - 5PM)"
    case allDay = "All Day"
} 