import Foundation
import SwiftUI

struct EmergencyContact: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let number: String
    let type: ContactType
    var relationship: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: EmergencyContact, rhs: EmergencyContact) -> Bool {
        lhs.id == rhs.id
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