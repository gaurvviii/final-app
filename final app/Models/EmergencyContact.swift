import Foundation
import SwiftUI

struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    let name: String
    let phone: String
    let relationship: String
    
    init(id: UUID = UUID(), name: String, phone: String, relationship: String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.relationship = relationship
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