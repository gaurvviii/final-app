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
    
    func loadMetroStations() {
        isLoading = true
        errorMessage = nil
        
        // Read the CSV file
        if let path = Bundle.main.path(forResource: "Namma_Metro_stations(Bengaluru)", ofType: "csv"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            let rows = content.components(separatedBy: .newlines)
            
            // Skip header row
            let dataRows = rows.dropFirst()
            
            metroStations = dataRows.compactMap { row in
                let columns = row.components(separatedBy: ",")
                guard columns.count >= 8 else { return nil }
                
                let number = Int(columns[0]) ?? 0
                let name = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let kannadaName = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let line = MetroStation.MetroLine(rawValue: columns[3].trimmingCharacters(in: .whitespacesAndNewlines)) ?? .purple
                let openedDate = parseDate(columns[4])
                let day = columns[5].trimmingCharacters(in: .whitespacesAndNewlines)
                let layout = MetroStation.StationLayout(rawValue: columns[6].trimmingCharacters(in: .whitespacesAndNewlines)) ?? .elevated
                let abbreviation = columns[7].trimmingCharacters(in: .whitespacesAndNewlines)
                
                return MetroStation(
                    number: number,
                    name: name,
                    kannadaName: kannadaName,
                    line: line,
                    openedDate: openedDate,
                    day: day,
                    layout: layout,
                    abbreviation: abbreviation,
                    coordinate: extractCoordinates(from: name)
                )
            }
        } else {
            errorMessage = "Failed to load metro station data"
        }
        
        isLoading = false
    }
    
    private func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yy"
        return formatter.date(from: dateString) ?? Date()
    }
    
    private func extractCoordinates(from stationName: String) -> CLLocationCoordinate2D {
        // This is a placeholder - in a real app, you would use geocoding
        // For now, we'll use some default coordinates for Bangalore
        return CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
    }
    
    func getNearbyMetroStations(to location: CLLocation, radiusInMeters: Double = 2000) -> [MetroStation] {
        return metroStations.filter { station in
            let stationLocation = CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude)
            return stationLocation.distance(from: location) <= radiusInMeters
        }
    }
    
    func getStationsOnLine(_ line: MetroStation.MetroLine) -> [MetroStation] {
        return metroStations.filter { $0.line == line }
    }
} 