import Foundation
import SwiftUI
import CoreLocation
import CryptoKit

struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    let name: String
    let phone: String
    let relationship: String
    var customMessage: String
    var sendLocation: Bool
    
    init(id: UUID = UUID(), name: String, phone: String, relationship: String, 
         customMessage: String = "I'm in an emergency situation and need help!", sendLocation: Bool = true) {
        self.id = id
        self.name = name
        self.phone = phone
        self.relationship = relationship
        self.customMessage = customMessage
        self.sendLocation = sendLocation
    }
    
    private func encodeCoordinates(_ location: CLLocationCoordinate2D) -> String {
        // Simple coordinate encoding - shift and encode
        let shiftedLat = location.latitude + 90.0 // Shift latitude to positive range (0-180)
        let shiftedLong = location.longitude + 180.0 // Shift longitude to positive range (0-360)
        
        // Convert to integers (multiply by 10000 to preserve 4 decimal places)
        let latInt = Int(shiftedLat * 10000)
        let longInt = Int(shiftedLong * 10000)
        
        // Combine and encode
        let combined = "\(latInt):\(longInt)"
        let data = combined.data(using: .utf8) ?? Data()
        return data.base64EncodedString()
    }
    
    private func getLocationEmoji(_ location: CLLocationCoordinate2D) -> String {
        // Return different emojis based on time of day
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "🌅" // Morning
        case 12..<17: return "☀️" // Afternoon
        case 17..<20: return "🌆" // Evening
        default: return "🌙" // Night
        }
    }
    
    func generateSOSMessage(location: CLLocationCoordinate2D?) -> String {
        var message = "🆘 SOS ALERT!\n\n"
        message += customMessage + "\n\n"
        
        if sendLocation, let location = location {
            let emoji = getLocationEmoji(location)
            message += "\(emoji) Location Code: \(encodeCoordinates(location))\n"
            message += "📍 Maps Link: https://maps.google.com/maps?q=\(location.latitude),\(location.longitude)\n"
            
            // Add approximate address if available
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first {
                    var addressComponents: [String] = []
                    if let thoroughfare = placemark.thoroughfare {
                        addressComponents.append(thoroughfare)
                    }
                    if let locality = placemark.locality {
                        addressComponents.append(locality)
                    }
                    if !addressComponents.isEmpty {
                        message += "\n📍 Near: \(addressComponents.joined(separator: ", "))"
                    }
                }
            }
        }
        
        message += "\n\nPlease contact emergency services if you cannot reach me."
        return message
    }
    
    // Decode location (for receivers of the message)
    static func decodeLocation(from code: String) -> CLLocationCoordinate2D? {
        guard let data = Data(base64Encoded: code),
              let decoded = String(data: data, encoding: .utf8),
              let separatorIndex = decoded.firstIndex(of: ":"),
              let latInt = Int(decoded[..<separatorIndex]),
              let longInt = Int(decoded[decoded.index(after: separatorIndex)...]) else {
            return nil
        }
        
        // Convert back to coordinates
        let latitude = (Double(latInt) / 10000.0) - 90.0
        let longitude = (Double(longInt) / 10000.0) - 180.0
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum ContactType: String, Hashable {
    case emergency = "Emergency"
    case medical = "Medical"
    case helpline = "Helpline"
    case personal = "Personal"
    
    var icon: String {
        switch self {
        case .emergency: return "exclamationmark.triangle.fill"
        case .medical: return "cross.fill"
        case .helpline: return "phone.fill"
        case .personal: return "person.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .emergency: return .red
        case .medical: return .blue
        case .helpline: return AppTheme.primaryPurple
        case .personal: return .green
        }
    }
} 