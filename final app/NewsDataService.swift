import Foundation
import CoreLocation
import MapKit
import NaturalLanguage

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [CrimeNews]
    let nextPage: String?
}

struct CrimeNews: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String?
    let content: String?
    let link: String
    let pubDate: String
    let location: String?
    var coordinates: CLLocationCoordinate2D?
    
    enum CodingKeys: String, CodingKey {
        case title, description, content, link, pubDate, location
    }
}

struct DangerZone: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let radius: CLLocationDistance
    let intensity: Double
    let title: String
    let description: String
}

struct SafeZone: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let radius: CLLocationDistance
    let safetyScore: Double // 0.0 to 1.0, where 1.0 is safest
    let name: String
    let description: String
}

class NewsDataService: ObservableObject {
    @Published var crimeNews: [CrimeNews] = []
    @Published var dangerZones: [DangerZone] = []
    @Published var safeZones: [SafeZone] = []
    private let apiKey = "pub_800030f722a25b3bb98bd09ec91b8c928386d"
    private let baseURL = "https://newsdata.io/api/1/news"
    private let geocoder = CLGeocoder()
    
    func testAPI() {
        print("Testing NewsData.io API connection...")
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "q", value: "crime women"),
            URLQueryItem(name: "country", value: "in"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "size", value: "5")
        ]
        
        guard let url = components.url else {
            print("❌ Error: Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ Error: No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(NewsResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self?.crimeNews = response.articles
                    self?.processLocations(from: response.articles)
                    self?.updateSafeZones()
                }
            } catch {
                print("❌ Decoding Error: \(error)")
            }
        }
        
        task.resume()
    }
    
    func fetchCrimeNews(completion: @escaping (Result<[CrimeNews], Error>) -> Void) {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "q", value: "crime women"),
            URLQueryItem(name: "country", value: "in"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "size", value: "10")
        ]
        
        guard let url = components.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(NewsResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self?.crimeNews = response.articles
                    self?.processLocations(from: response.articles)
                    self?.updateSafeZones()
                    completion(.success(response.articles))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func processLocations(from news: [CrimeNews]) {
        for article in news {
            // Extract location from title and description
            let locationText = extractLocation(from: article)
            
            // Geocode the location
            geocoder.geocodeAddressString(locationText) { [weak self] placemarks, error in
                guard let placemark = placemarks?.first,
                      let location = placemark.location else {
                    print("❌ Could not geocode location: \(locationText)")
                    return
                }
                
                let coordinate = location.coordinate
                
                // Create a danger zone
                let dangerZone = DangerZone(
                    coordinate: coordinate,
                    radius: 500, // 500 meters radius
                    intensity: 0.7, // High intensity
                    title: article.title,
                    description: article.description ?? "No description available"
                )
                
                DispatchQueue.main.async {
                    self?.dangerZones.append(dangerZone)
                }
            }
        }
    }
    
    private func extractLocation(from news: CrimeNews) -> String {
        // First try to extract from title
        if let location = extractLocationFromText(news.title) {
            return location
        }
        
        // Then try description
        if let description = news.description,
           let location = extractLocationFromText(description) {
            return location
        }
        
        // If no location found, return a default location
        return "Bangalore, India"
    }
    
    private func extractLocationFromText(_ text: String) -> String? {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        var locations: [String] = []
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, tokenRange in
            if tag == .placeName {
                let location = String(text[tokenRange])
                locations.append(location)
            }
            return true
        }
        
        // Return the first location found, or nil if none
        return locations.first
    }
    
    private func extractCoordinates(from location: String) async -> CLLocationCoordinate2D? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(location)
            if let placemark = placemarks.first,
               let location = placemark.location {
                return location.coordinate
            }
        } catch {
            print("Geocoding error: \(error.localizedDescription)")
        }
        return nil
    }
    
    private func processNewsLocations() async {
        for (index, news) in crimeNews.enumerated() {
            if let location = news.location {
                if let coordinates = await extractCoordinates(from: location) {
                    crimeNews[index].coordinates = coordinates
                }
            }
        }
    }
    
    private func updateSafeZones() {
        // Clear existing safe zones
        safeZones.removeAll()
        
        // Create safe zones around police stations
        let policeStations = [
            (name: "Central Police Station", coordinate: CLLocationCoordinate2D(latitude: 12.9775, longitude: 77.5946), radius: 1000.0),
            (name: "South Police Station", coordinate: CLLocationCoordinate2D(latitude: 12.9675, longitude: 77.5846), radius: 1000.0),
            (name: "North Police Station", coordinate: CLLocationCoordinate2D(latitude: 12.9875, longitude: 77.6046), radius: 1000.0)
        ]
        
        for station in policeStations {
            let safeZone = SafeZone(
                coordinate: station.coordinate,
                radius: station.radius,
                safetyScore: 0.9, // High safety score near police stations
                name: station.name,
                description: "Area patrolled by \(station.name)"
            )
            safeZones.append(safeZone)
        }
        
        // Create safe zones in areas with no recent crime reports
        let safeAreas = [
            (name: "Commercial District", coordinate: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946), radius: 1500.0),
            (name: "Residential Area", coordinate: CLLocationCoordinate2D(latitude: 12.9816, longitude: 77.5846), radius: 1200.0)
        ]
        
        for area in safeAreas {
            let safeZone = SafeZone(
                coordinate: area.coordinate,
                radius: area.radius,
                safetyScore: 0.8, // Good safety score for monitored areas
                name: area.name,
                description: "Regularly monitored \(area.name)"
            )
            safeZones.append(safeZone)
        }
    }
} 