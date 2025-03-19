import Foundation
import MapKit
import SwiftUI

struct UnsafeArea: Identifiable {
    let id = UUID()
    let name: String
    let riskLevel: RiskLevel
    let crimeDescription: String
    let coordinates: CLLocationCoordinate2D
    let timeOfDay: TimeOfDay
    
    var color: Color {
        switch riskLevel {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .yellow
        }
    }
}

enum RiskLevel: String {
    case high = "High Risk"
    case medium = "Medium Risk"
    case low = "Low Risk"
}

enum TimeOfDay: String {
    case night = "Night (9PM - 5AM)"
    case evening = "Evening (5PM - 9PM)"
    case allDay = "All Day"
}

// Sample data based on analysis of crime patterns
// In a real app, this would be generated from actual crime data analysis
let unsafeAreas: [UnsafeArea] = [
    UnsafeArea(
        name: "Majestic Area",
        riskLevel: .high,
        crimeDescription: "High incidents of harassment and theft at night",
        coordinates: CLLocationCoordinate2D(latitude: 12.9766, longitude: 77.5713),
        timeOfDay: .night
    ),
    UnsafeArea(
        name: "Shivajinagar",
        riskLevel: .medium,
        crimeDescription: "Moderate risk in isolated streets after dark",
        coordinates: CLLocationCoordinate2D(latitude: 12.9850, longitude: 77.6011),
        timeOfDay: .evening
    ),
    UnsafeArea(
        name: "K.R. Market surroundings",
        riskLevel: .medium,
        crimeDescription: "Crowded area with moderate risk of theft and harassment",
        coordinates: CLLocationCoordinate2D(latitude: 12.9688, longitude: 77.5764),
        timeOfDay: .allDay
    ),
    UnsafeArea(
        name: "Outer Ring Road (Marathahalli)",
        riskLevel: .medium,
        crimeDescription: "Poorly lit stretches with higher risk at night",
        coordinates: CLLocationCoordinate2D(latitude: 12.9591, longitude: 77.6974),
        timeOfDay: .night
    ),
    UnsafeArea(
        name: "Peenya Industrial Area",
        riskLevel: .high,
        crimeDescription: "Isolated industrial zones with poor visibility at night",
        coordinates: CLLocationCoordinate2D(latitude: 13.0302, longitude: 77.5192),
        timeOfDay: .night
    ),
    UnsafeArea(
        name: "BTM Layout late night",
        riskLevel: .low,
        crimeDescription: "Some incidents reported in poorly lit areas",
        coordinates: CLLocationCoordinate2D(latitude: 12.9166, longitude: 77.6101),
        timeOfDay: .night
    ),
    UnsafeArea(
        name: "Electronic City Outskirts",
        riskLevel: .medium,
        crimeDescription: "Remote areas with limited security presence",
        coordinates: CLLocationCoordinate2D(latitude: 12.8452, longitude: 77.6602),
        timeOfDay: .night
    ),
    UnsafeArea(
        name: "Whitefield Back Roads",
        riskLevel: .medium,
        crimeDescription: "Isolated roads connecting tech parks with limited traffic at night",
        coordinates: CLLocationCoordinate2D(latitude: 12.9698, longitude: 77.7499),
        timeOfDay: .night
    )
]

// Function to determine if a location is in or near an unsafe area
func nearbyUnsafeAreas(to location: CLLocation, radiusInMeters: Double = 3000) -> [UnsafeArea] {
    var nearbyAreas: [UnsafeArea] = []
    
    for area in unsafeAreas {
        let areaLocation = CLLocation(
            latitude: area.coordinates.latitude,
            longitude: area.coordinates.longitude
        )
        
        let distance = location.distance(from: areaLocation)
        if distance <= radiusInMeters {
            nearbyAreas.append(area)
        }
    }
    
    return nearbyAreas
} 