import Foundation
import MapKit

struct MetroStation: Identifiable {
    let id = UUID()
    let number: Int
    let name: String
    let kannadaName: String
    let line: MetroLine
    let openedDate: Date
    let day: String
    let layout: StationLayout
    let abbreviation: String
    let coordinate: CLLocationCoordinate2D
    var distance: Double = 0.0
    
    enum MetroLine: String {
        case purple = "Purple Line"
        case green = "Green Line"
        // Delhi Metro Lines
        case red = "Red Line"
        case yellow = "Yellow Line"
        case blue = "Blue Line"
        case violet = "Violet Line"
        case magenta = "Magenta Line"
        case pink = "Pink Line"
        case aqua = "Aqua Line"
        case gray = "Gray Line"
        case orange = "Orange Line"
        case rapid = "Rapid Metro"
    }
    
    enum StationLayout: String {
        case elevated = "Elevated"
        case atGrade = "At Grade"
        case underground = "Underground"
    }
}

// Delhi Metro Stations data (hardcoded)
let delhiMetroStations = [
    // Red Line
    MetroStation(
        number: 1,
        name: "Rithala",
        kannadaName: "",
        line: .red,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "RITH",
        coordinate: CLLocationCoordinate2D(latitude: 28.72072, longitude: 77.10713)
    ),
    MetroStation(
        number: 2,
        name: "Rohini West",
        kannadaName: "",
        line: .red,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "ROHW",
        coordinate: CLLocationCoordinate2D(latitude: 28.71483, longitude: 77.11467)
    ),
    MetroStation(
        number: 3,
        name: "Rohini East",
        kannadaName: "",
        line: .red,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "ROHE",
        coordinate: CLLocationCoordinate2D(latitude: 28.7076, longitude: 77.12591)
    ),
    MetroStation(
        number: 4,
        name: "Pitam Pura",
        kannadaName: "",
        line: .red,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "PITP",
        coordinate: CLLocationCoordinate2D(latitude: 28.70317, longitude: 77.13223)
    ),
    MetroStation(
        number: 5,
        name: "Kohat Enclave",
        kannadaName: "",
        line: .red,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "KOHE",
        coordinate: CLLocationCoordinate2D(latitude: 28.6981, longitude: 77.14024)
    ),
    
    // Yellow Line
    MetroStation(
        number: 6,
        name: "Samaypur Badli",
        kannadaName: "",
        line: .yellow,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "SAMB",
        coordinate: CLLocationCoordinate2D(latitude: 28.7446158, longitude: 77.1382654)
    ),
    MetroStation(
        number: 7,
        name: "Rohini Sector 18-19",
        kannadaName: "",
        line: .yellow,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "ROH1",
        coordinate: CLLocationCoordinate2D(latitude: 28.7383477, longitude: 77.1398323)
    ),
    MetroStation(
        number: 8,
        name: "Haiderpur Badli Mor",
        kannadaName: "",
        line: .yellow,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "HAID",
        coordinate: CLLocationCoordinate2D(latitude: 28.7301214, longitude: 77.1494029)
    ),
    MetroStation(
        number: 9,
        name: "Jahangirpuri",
        kannadaName: "",
        line: .yellow,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "JAHA",
        coordinate: CLLocationCoordinate2D(latitude: 28.72592, longitude: 77.16267)
    ),
    MetroStation(
        number: 10,
        name: "Adarsh Nagar",
        kannadaName: "",
        line: .yellow,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "ADAR",
        coordinate: CLLocationCoordinate2D(latitude: 28.71642, longitude: 77.17046)
    ),
    
    // Blue Line
    MetroStation(
        number: 11,
        name: "Dwarka Sector 21",
        kannadaName: "",
        line: .blue,
        openedDate: Date(),
        day: "Monday",
        layout: .underground,
        abbreviation: "DW21",
        coordinate: CLLocationCoordinate2D(latitude: 28.55226, longitude: 77.05828)
    ),
    MetroStation(
        number: 12,
        name: "Dwarka Sector 8",
        kannadaName: "",
        line: .blue,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "DW08",
        coordinate: CLLocationCoordinate2D(latitude: 28.56583, longitude: 77.06706)
    ),
    MetroStation(
        number: 13,
        name: "Dwarka Sector 9",
        kannadaName: "",
        line: .blue,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "DW09",
        coordinate: CLLocationCoordinate2D(latitude: 28.57487, longitude: 77.06454)
    ),
    MetroStation(
        number: 14,
        name: "Dwarka Sector 10",
        kannadaName: "",
        line: .blue,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "DW10",
        coordinate: CLLocationCoordinate2D(latitude: 28.58068, longitude: 77.05682)
    ),
    MetroStation(
        number: 15,
        name: "Dwarka Sector 11",
        kannadaName: "",
        line: .blue,
        openedDate: Date(),
        day: "Monday",
        layout: .elevated,
        abbreviation: "DW11",
        coordinate: CLLocationCoordinate2D(latitude: 28.58657, longitude: 77.04929)
    ),
    
    // Violet Line  
    MetroStation(
        number: 16,
        name: "Kashmere Gate",
        kannadaName: "",
        line: .violet,
        openedDate: Date(),
        day: "Monday",
        layout: .underground,
        abbreviation: "KASH",
        coordinate: CLLocationCoordinate2D(latitude: 28.6675, longitude: 77.22817)
    ),
    MetroStation(
        number: 17,
        name: "Lal Quila",
        kannadaName: "",
        line: .violet,
        openedDate: Date(),
        day: "Monday",
        layout: .underground,
        abbreviation: "LALQ",
        coordinate: CLLocationCoordinate2D(latitude: 28.6556, longitude: 77.2407)
    ),
    MetroStation(
        number: 18,
        name: "Jama Masjid",
        kannadaName: "",
        line: .violet,
        openedDate: Date(),
        day: "Monday",
        layout: .underground,
        abbreviation: "JAMA",
        coordinate: CLLocationCoordinate2D(latitude: 28.65001015, longitude: 77.23767617)
    ),
    MetroStation(
        number: 19,
        name: "Delhi Gate",
        kannadaName: "",
        line: .violet,
        openedDate: Date(),
        day: "Monday",
        layout: .underground,
        abbreviation: "DELG",
        coordinate: CLLocationCoordinate2D(latitude: 28.6392036, longitude: 77.2407823)
    ),
    MetroStation(
        number: 20,
        name: "ITO",
        kannadaName: "",
        line: .violet,
        openedDate: Date(),
        day: "Monday",
        layout: .underground,
        abbreviation: "ITO",
        coordinate: CLLocationCoordinate2D(latitude: 28.6305091, longitude: 77.2414363)
    )
]

// Data service to load and manage metro station data
class MetroDataService: ObservableObject {
    @Published var metroStations: [MetroStation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    

    init() {
        loadMetroStations()
    }
    
    func loadMetroStations() {
        isLoading = true
        errorMessage = nil
        
        // Load Bangalore metro data and combine with Delhi
        let bangaloreMetroStations = [
            MetroStation(
                number: 1,
                name: "Baiyappanahalli",
                kannadaName: "ಬೈಯಪ್ಪನಹಳ್ಳಿ",
                line: .purple,
                openedDate: Date(),
                day: "Monday",
                layout: .elevated,
                abbreviation: "BYPL",
                coordinate: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
            ),
            MetroStation(
                number: 2,
                name: "Swami Vivekananda Road",
                kannadaName: "ಸ್ವಾಮಿ ವಿವೇಕಾನಂದ ರಸ್ತೆ",
                line: .purple,
                openedDate: Date(),
                day: "Monday",
                layout: .elevated,
                abbreviation: "SVRO",
                coordinate: CLLocationCoordinate2D(latitude: 12.9816, longitude: 77.6046)
            ),
            MetroStation(
                number: 3,
                name: "Indiranagar",
                kannadaName: "ಇಂದಿರಾನಗರ",
                line: .purple,
                openedDate: Date(),
                day: "Monday",
                layout: .elevated,
                abbreviation: "INDA",
                coordinate: CLLocationCoordinate2D(latitude: 12.9916, longitude: 77.6146)
            )
        ]
        
        metroStations = bangaloreMetroStations + delhiMetroStations
        isLoading = false
    }
    
    func getMetroStations(for city: String) -> [MetroStation] {
        switch city.lowercased() {
        case "bangalore", "bengaluru":
            return metroStations.filter { station in
                let coord = station.coordinate
                return coord.latitude >= 12.8 && coord.latitude <= 13.2 && 
                       coord.longitude >= 77.4 && coord.longitude <= 77.8
            }
        case "delhi":
            return delhiMetroStations
        default:
            return metroStations
        }
    }
    
    func getNearbyMetroStations(to location: CLLocation) -> [MetroStation] {
        return metroStations.map { station in
            var updatedStation = station
            let stationLocation = CLLocation(
                latitude: station.coordinate.latitude,
                longitude: station.coordinate.longitude
            )
            updatedStation.distance = location.distance(from: stationLocation)
            return updatedStation
        }.sorted { (station1: MetroStation, station2: MetroStation) -> Bool in
            return station1.distance < station2.distance
        }
    }
    
    func getStationsOnLine(_ line: MetroStation.MetroLine) -> [MetroStation] {
        return metroStations.filter { $0.line == line }
    }
} 