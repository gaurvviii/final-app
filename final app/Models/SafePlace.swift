import Foundation
import MapKit

struct SafePlace: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let type: SafePlaceType
    let address: String
    let phone: String
}

enum SafePlaceType {
    case police
    case hospital
    case safeZone
}

// Sample Data
let safePlaces = [
    SafePlace(
        name: "Central Police Station",
        coordinate: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        type: .police,
        address: "Cubbon Park Police Station, Kasturba Road, Bangalore",
        phone: "080-22942675"
    ),
    SafePlace(
        name: "City Hospital",
        coordinate: CLLocationCoordinate2D(latitude: 12.9800, longitude: 77.5883),
        type: .hospital,
        address: "Bowring & Lady Curzon Hospital, Shivaji Nagar",
        phone: "080-22867000"
    ),
    SafePlace(
        name: "Women's Safety Hub",
        coordinate: CLLocationCoordinate2D(latitude: 12.9141, longitude: 77.5673),
        type: .safeZone,
        address: "Women Police Station, Banashankari",
        phone: "080-22943250"
    )
] 