import Foundation
import MapKit
import Combine
import SwiftUI

class CrimeDataService: ObservableObject {
    private let apiKey = "579b464db66ec23bdd00000167daec9fa3494ec04d11d28a96eefe70"
    private let baseURL = "https://api.data.gov.in/resource"
    
    @Published var crimeHotspots: [CrimeHotspot] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadLocalCrimeData()
    }
    
    func fetchCrimeData() {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "/579b464db66ec23bdd00000167daec9fa3494ec04d11d28a96eefe70"
        let queryParams = [
            "api-key": apiKey,
            "format": "json",
            "limit": "100"
        ]
        
        var components = URLComponents(string: baseURL + endpoint)
        components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components?.url else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: CrimeDataResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    // Fall back to local data if API fails
                    self.loadLocalCrimeData()
                }
            } receiveValue: { response in
                self.processCrimeData(response)
            }
            .store(in: &cancellables)
    }
    
    // Process API response into crime hotspots
    private func processCrimeData(_ response: CrimeDataResponse) {
        // API response processing would go here
        // For now, we'll use hardcoded data since we don't have the actual API structure
        loadLocalCrimeData()
    }
    
    // Load local crime data based on the police and crime CSV data
    private func loadLocalCrimeData() {
        // Bangalore hotspots based on police data
        self.crimeHotspots = [
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
            ),
            // Delhi data
            CrimeHotspot(
                id: UUID(),
                city: "Delhi",
                area: "Paharganj",
                coordinate: CLLocationCoordinate2D(latitude: 28.6466, longitude: 77.2165),
                crimeCount: 205,
                crimeTypes: ["Assault", "Harassment", "Theft"],
                riskLevel: .high,
                timePattern: .night
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Delhi",
                area: "Saket",
                coordinate: CLLocationCoordinate2D(latitude: 28.5280, longitude: 77.2152),
                crimeCount: 118,
                crimeTypes: ["Harassment", "Stalking"],
                riskLevel: .medium,
                timePattern: .evening
            ),
            // Mumbai data
            CrimeHotspot(
                id: UUID(),
                city: "Mumbai",
                area: "Dharavi",
                coordinate: CLLocationCoordinate2D(latitude: 19.0380, longitude: 72.8538),
                crimeCount: 178,
                crimeTypes: ["Theft", "Assault"],
                riskLevel: .high,
                timePattern: .night
            ),
            CrimeHotspot(
                id: UUID(),
                city: "Mumbai",
                area: "Dadar",
                coordinate: CLLocationCoordinate2D(latitude: 19.0178, longitude: 72.8478),
                crimeCount: 132,
                crimeTypes: ["Harassment", "Theft"],
                riskLevel: .medium,
                timePattern: .evening
            ),
            // Chennai data
            CrimeHotspot(
                id: UUID(),
                city: "Chennai",
                area: "T. Nagar",
                coordinate: CLLocationCoordinate2D(latitude: 13.0418, longitude: 80.2341),
                crimeCount: 143,
                crimeTypes: ["Harassment", "Theft"],
                riskLevel: .medium,
                timePattern: .evening
            ),
            // Kolkata data
            CrimeHotspot(
                id: UUID(),
                city: "Kolkata",
                area: "Park Street",
                coordinate: CLLocationCoordinate2D(latitude: 22.5506, longitude: 88.3498),
                crimeCount: 167,
                crimeTypes: ["Harassment", "Assault"],
                riskLevel: .high,
                timePattern: .night
            )
        ]
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