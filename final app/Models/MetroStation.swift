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
    }
    
    enum StationLayout: String {
        case elevated = "Elevated"
        case atGrade = "At Grade"
        case underground = "Underground"
    }
}

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
        
        // Use local data
        metroStations = [
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
        isLoading = false
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