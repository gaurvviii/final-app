import Foundation
import MapKit

struct CrimeData: Identifiable {
    let id = UUID()
    let year: Int
    let state: String
    let district: String
    let crimeType: String
    let count: Int
    let coordinate: CLLocationCoordinate2D
    
    enum CrimeType: String {
        case rape = "Rape"
        case kidnapping = "Kidnapping & Abduction"
        case dowry = "Dowry Deaths"
        case assault = "Assault on Women with Intent to Outrage her Modesty"
        case insult = "Insult to Modesty of Women"
        case cruelty = "Cruelty by Husband or his Relatives"
        case trafficking = "Importation of Girls"
        case other = "Other Crimes"
    }
}

// Helper functions for crime data processing
func extractCoordinates(from district: String) -> CLLocationCoordinate2D {
    // This is a placeholder - in a real app, you would use geocoding
    // For now, we'll use some default coordinates for Bangalore
    return CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
}

func calculateRiskLevel(totalCrimes: Int) -> RiskLevel {
    if totalCrimes > 100 {
        return .high
    } else if totalCrimes > 50 {
        return .medium
    } else {
        return .low
    }
} 