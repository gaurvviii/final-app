import Foundation
import CoreLocation

struct CSVParser {
    static func parseMetroStations(from csvContent: String) -> [MetroStation] {
        var stations: [MetroStation] = []
        let lines = csvContent.components(separatedBy: .newlines)
        
        // Skip header line
        for i in 1..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty { continue }
            
            let columns = parseCSVLine(line)
            
            // CSV structure: ID,Station Names,Dist,Metro Line,Opened(Year),Layout,Latitude,Longitude
            guard columns.count >= 8,
                  let stationId = Int(columns[0]),
                  let latitude = Double(columns[6]),
                  let longitude = Double(columns[7]),
                  latitude >= 20.0 && latitude <= 35.0,  // Valid latitude for Delhi region
                  longitude >= 70.0 && longitude <= 85.0 else {  // Valid longitude for Delhi region
                print("⚠️ Skipping invalid station data: \(columns)")
                continue
            }
            
            let stationName = columns[1]
            let metroLine = columns[3]
            let layout = columns[5]
            let openedYear = columns[4]
            
            // Create metro line enum
            let lineType: MetroStation.MetroLine
            let lowerCaseLine = metroLine.lowercased()
            if lowerCaseLine.contains("red") {
                lineType = .red
            } else if lowerCaseLine.contains("yellow") {
                lineType = .yellow
            } else if lowerCaseLine.contains("blue") {
                lineType = .blue
            } else if lowerCaseLine.contains("green") {
                lineType = .green
            } else if lowerCaseLine.contains("violet") {
                lineType = .violet
            } else if lowerCaseLine.contains("magenta") {
                lineType = .magenta
            } else if lowerCaseLine.contains("pink") {
                lineType = .pink
            } else if lowerCaseLine.contains("aqua") {
                lineType = .aqua
            } else if lowerCaseLine.contains("gray") {
                lineType = .gray
            } else if lowerCaseLine.contains("orange") {
                lineType = .orange
            } else if lowerCaseLine.contains("rapid") {
                lineType = .rapid
            } else {
                lineType = .blue
            }
            
            // Create layout type
            let layoutType: MetroStation.StationLayout
            switch layout.lowercased() {
            case "elevated":
                layoutType = .elevated
            case "underground":
                layoutType = .underground
            case "at-grade":
                layoutType = .atGrade
            default:
                layoutType = .elevated
            }
            
            let station = MetroStation(
                number: stationId,
                name: stationName,
                kannadaName: "", // Delhi stations don't have Kannada names
                line: lineType,
                openedDate: Date(), // Could parse the year if needed
                day: "Monday", // Default value
                layout: layoutType,
                abbreviation: String(stationName.prefix(4)).uppercased(),
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            )
            
            stations.append(station)
        }
        
        return stations
    }
    
    private static func parseCSVLine(_ line: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                columns.append(currentColumn.trimmingCharacters(in: .whitespacesAndNewlines))
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
            
            i = line.index(after: i)
        }
        
        // Add the last column
        columns.append(currentColumn.trimmingCharacters(in: .whitespacesAndNewlines))
        
        return columns
    }
} 