import Foundation
import MapKit

struct PoliceStation: Identifiable {
    let id = UUID()
    let name: String
    let stationCode: String
    let address: String
    let phoneNumber: String
    let division: String
    let coordinates: CLLocationCoordinate2D
    
    var distance: Double = 0.0 // Will be calculated based on user location
}

// Sample data from the CSV file
let bangalorePoliceStations: [PoliceStation] = [
    PoliceStation(
        name: "Cubbon Park",
        stationCode: "1644315",
        address: "7 Cubbon Park Police Station, Kasturba Road, Bangalore 560001",
        phoneNumber: "080-22942675",
        division: "Central Division",
        coordinates: CLLocationCoordinate2D(latitude: 12.9762, longitude: 77.5929)
    ),
    PoliceStation(
        name: "Vidhanasoudha",
        stationCode: "1644390",
        address: "Vidhana Soudha West Gate, Bangalore 560001",
        phoneNumber: "080-22942590",
        division: "Central Division",
        coordinates: CLLocationCoordinate2D(latitude: 12.9797, longitude: 77.5912)
    ),
    PoliceStation(
        name: "Ulsoor",
        stationCode: "1644384",
        address: "Ulsoor, Bangalore 560008",
        phoneNumber: "080-22942540",
        division: "East Division",
        coordinates: CLLocationCoordinate2D(latitude: 12.9718, longitude: 77.6186)
    ),
    PoliceStation(
        name: "Indiranagar",
        stationCode: "1644337",
        address: "Indira Nagar P.S., Old Madras Road, Bangalore 560038",
        phoneNumber: "080-22942658",
        division: "East Division",
        coordinates: CLLocationCoordinate2D(latitude: 12.9784, longitude: 77.6408)
    ),
    PoliceStation(
        name: "Koramangala",
        stationCode: "1644350",
        address: "No.8/A, 20th Main, 6th Block, Koramangala, Bangalore 560095",
        phoneNumber: "080-25503726",
        division: "South East Division",
        coordinates: CLLocationCoordinate2D(latitude: 12.9352, longitude: 77.6245)
    ),
    PoliceStation(
        name: "J.P. Nagar",
        stationCode: "1644344",
        address: "Ca Site No.36, 21st Main, 7th Cross, 2nd Phase, J.P.Nagar, Bangalore 560078",
        phoneNumber: "080-22942563",
        division: "South Division",
        coordinates: CLLocationCoordinate2D(latitude: 12.9102, longitude: 77.5922)
    ),
    PoliceStation(
        name: "Jayanagar",
        stationCode: "1644341",
        address: "No 7677, Swagath Main Road, 30th Cross Tilak Nagar, Bangalore",
        phoneNumber: "080-22942562",
        division: "South Division",
        coordinates: CLLocationCoordinate2D(latitude: 12.9299, longitude: 77.5932)
    ),
    PoliceStation(
        name: "Women Police Station",
        stationCode: "1644362",
        address: "Banashankari, Bangalore",
        phoneNumber: "080-22943250",
        division: "South Division",
        coordinates: CLLocationCoordinate2D(latitude: 12.9141, longitude: 77.5673)
    ),
    PoliceStation(
        name: "Hebbal",
        stationCode: "1644334",
        address: "Hebbala P.S., Hebbala, Bellary Road, Bangalore 560024",
        phoneNumber: "080-22942535",
        division: "North Division",
        coordinates: CLLocationCoordinate2D(latitude: 13.0358, longitude: 77.5970)
    ),
    PoliceStation(
        name: "Malleswaram",
        stationCode: "1644357",
        address: "Malleswaram P.S. No.47, 5th cross, M.K.K. Road, Malleswaram, Bangalore 560003",
        phoneNumber: "080-22942519",
        division: "North Division",
        coordinates: CLLocationCoordinate2D(latitude: 12.9955, longitude: 77.5706)
    )
]

// Function to find nearest police stations to a given location
func nearestPoliceStations(to location: CLLocation, limit: Int = 5) -> [PoliceStation] {
    var stations = bangalorePoliceStations
    
    // Calculate distance for each station
    for i in 0..<stations.count {
        let stationLocation = CLLocation(
            latitude: stations[i].coordinates.latitude,
            longitude: stations[i].coordinates.longitude
        )
        let distance = location.distance(from: stationLocation)
        stations[i].distance = distance
    }
    
    // Sort by distance and return the closest ones
    return stations.sorted { $0.distance < $1.distance }.prefix(limit).map { $0 }
} 