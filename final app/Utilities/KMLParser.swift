import Foundation
import CoreLocation

struct KMLParser {
    static func parsePoliceStations(from kmlContent: String) -> [PoliceStation] {
        var stations: [PoliceStation] = []
        
        // Extract all placemark data
        let placemarkPattern = #"<Placemark>.*?</Placemark>"#
        guard let placemarkRegex = try? NSRegularExpression(pattern: placemarkPattern, options: [.dotMatchesLineSeparators]) else {
            return stations
        }
        
        let matches = placemarkRegex.matches(in: kmlContent, range: NSRange(kmlContent.startIndex..., in: kmlContent))
        
        for match in matches {
            if let range = Range(match.range, in: kmlContent) {
                let placemarkXML = String(kmlContent[range])
                
                // Extract name
                let namePattern = #"<SimpleData name="NAME">(.*?)</SimpleData>"#
                guard let nameRegex = try? NSRegularExpression(pattern: namePattern),
                      let nameMatch = nameRegex.firstMatch(in: placemarkXML, range: NSRange(placemarkXML.startIndex..., in: placemarkXML)),
                      let nameRange = Range(nameMatch.range(at: 1), in: placemarkXML) else {
                    continue
                }
                let name = String(placemarkXML[nameRange])
                
                // Extract district
                let districtPattern = #"<SimpleData name="DISTRICT">(.*?)</SimpleData>"#
                let district: String
                if let districtRegex = try? NSRegularExpression(pattern: districtPattern),
                   let districtMatch = districtRegex.firstMatch(in: placemarkXML, range: NSRange(placemarkXML.startIndex..., in: placemarkXML)),
                   let districtRange = Range(districtMatch.range(at: 1), in: placemarkXML) {
                    district = String(placemarkXML[districtRange])
                } else {
                    district = "Unknown"
                }
                
                // Extract coordinates
                let coordPattern = #"<coordinates>(.*?)</coordinates>"#
                guard let coordRegex = try? NSRegularExpression(pattern: coordPattern),
                      let coordMatch = coordRegex.firstMatch(in: placemarkXML, range: NSRange(placemarkXML.startIndex..., in: placemarkXML)),
                      let coordRange = Range(coordMatch.range(at: 1), in: placemarkXML) else {
                    continue
                }
                
                let coordString = String(placemarkXML[coordRange])
                let coordComponents = coordString.split(separator: ",")
                
                guard coordComponents.count >= 2,
                      let longitude = Double(coordComponents[0]),
                      let latitude = Double(coordComponents[1]) else {
                    continue
                }
                
                let station = PoliceStation(
                    name: name,
                    phoneNumber: "100", // Default police number
                    coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    address: "\(name), \(district) District, Delhi"
                )
                
                stations.append(station)
            }
        }
        
        return stations
    }
} 