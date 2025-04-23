import Foundation
import CoreLocation
import MapKit
import NaturalLanguage

class NewsDataService: ObservableObject {
    @Published var crimeNews: [NewsItem] = []
    private let apiKey = "5cde20636ba24dafa9325ae5383f3e9c"
    private let keywords = [
        "crime", "safety", "women", "attack", "assault", "harassment",
        "rape", "molestation", "sexual assault", "women safety",
        "girl attacked", "violence against women", "India",
        // Add more India-specific keywords
        "Delhi", "Mumbai", "Bangalore", "Chennai", "Hyderabad",
        "Kolkata", "Pune", "Ahmedabad", "Jaipur", "Lucknow",
        "Indian police", "Indian court", "Indian law", "Indian government",
        "Indian city", "Indian state", "Indian district", "Indian village"
    ]
    private var retryCount = 0
    private let maxRetries = 3
    private let userDefaults = UserDefaults.standard
    private let storedNewsKey = "storedCrimeNews"
    private let maxStoredNews = 100 // Maximum number of news items to store
    
    // India's approximate bounding box coordinates
    private let indiaBoundingBox = (
        minLat: 6.0, maxLat: 38.0,
        minLon: 68.0, maxLon: 98.0
    )
    
    // Check if coordinates are within India's boundaries
    private func isInIndia(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude >= indiaBoundingBox.minLat &&
               coordinate.latitude <= indiaBoundingBox.maxLat &&
               coordinate.longitude >= indiaBoundingBox.minLon &&
               coordinate.longitude <= indiaBoundingBox.maxLon
    }
    
    // Check if text contains India-specific content
    private func isIndiaRelated(_ text: String) -> Bool {
        let indiaKeywords = [
            "India", "Indian", "Delhi", "Mumbai", "Bangalore", "Chennai",
            "Hyderabad", "Kolkata", "Pune", "Ahmedabad", "Jaipur", "Lucknow",
            "police station", "police", "court", "district", "state",
            "village", "city", "town", "metro", "railway", "bus stand",
            "market", "college", "university", "hospital", "clinic"
        ]
        
        return indiaKeywords.contains { keyword in
            text.localizedCaseInsensitiveContains(keyword)
        }
    }
    
    // Load stored news from UserDefaults
    private func loadStoredNews() -> [NewsItem] {
        if let data = userDefaults.data(forKey: storedNewsKey),
           let storedNews = try? JSONDecoder().decode([NewsItem].self, from: data) {
            return storedNews
        }
        return []
    }
    
    // Save news to UserDefaults
    private func saveNews(_ news: [NewsItem]) {
        if let encoded = try? JSONEncoder().encode(news) {
            userDefaults.set(encoded, forKey: storedNewsKey)
        }
    }
    
    // Filter news based on distance from user's location
    private func filterNewsByLocation(_ news: [NewsItem], userLocation: CLLocation, maxDistance: CLLocationDistance = 5000) -> [NewsItem] {
        return news.filter { item in
            let newsLocation = CLLocation(latitude: item.coordinates.latitude, longitude: item.coordinates.longitude)
            return userLocation.distance(from: newsLocation) <= maxDistance
        }
    }
    
    func fetchCrimeNews(userLocation: CLLocation? = nil, completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        print("📡 Starting news fetch process...")
        print("📍 User location: \(userLocation?.coordinate.latitude ?? 0), \(userLocation?.coordinate.longitude ?? 0)")
        
        // First load stored news
        let storedNews = loadStoredNews()
        print("💾 Loaded \(storedNews.count) stored news items")
        
        // Calculate date range for past 48 hours
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let toDate = Date()
        let fromDate = Calendar.current.date(byAdding: .hour, value: -48, to: toDate)!
        
        let fromDateString = dateFormatter.string(from: fromDate)
        let toDateString = dateFormatter.string(from: toDate)
        
        print("📅 Fetching news from \(fromDateString) to \(toDateString)")
        
        // Try different query combinations
        let queryCombinations = [
            keywords.joined(separator: " OR "),
            "crime AND women AND India",
            "safety AND India",
            "women AND India"
        ]
        
        print("🔍 Using query combinations: \(queryCombinations)")
        
        let group = DispatchGroup()
        var allNewsItems: [NewsItem] = []
        
        for query in queryCombinations {
            group.enter()
            
            let urlString = "https://newsapi.org/v2/everything?q=\(query)&language=en&sortBy=publishedAt&from=\(fromDateString)&to=\(toDateString)&apiKey=\(apiKey)"
            
            print("📡 Fetching news with query: \(query)")
            
            guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: encodedUrlString) else {
                print("❌ Invalid URL for query: \(query)")
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                defer { group.leave() }
                
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Network error for query \(query): \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response for query \(query)")
                    return
                }
                
                print("📡 Response status code for query \(query): \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 429 {
                    print("⚠️ Rate limited for query \(query)")
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received for query \(query)")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let newsResponse = try decoder.decode(NewsAPIResponse.self, from: data)
                    
                    print("📡 Found \(newsResponse.articles.count) articles for query \(query)")
                    
                    let newNewsItems = newsResponse.articles.compactMap { article -> NewsItem? in
                        print("📰 Processing article: \(article.title)")
                        
                        let coordinate = self.extractLocationCoordinates(from: article.description ?? "")
                            ?? CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629)
                        
                        print("📍 Extracted coordinates: \(coordinate.latitude), \(coordinate.longitude)")
                        
                        // Check if article is India-related
                        let articleText = (article.title + " " + (article.description ?? "")).lowercased()
                        guard self.isIndiaRelated(articleText) || self.isInIndia(coordinate) else {
                            print("📍 Skipping non-Indian article: \(article.title)")
                            return nil
                        }
                        
                        let distance = userLocation?.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) ?? 0
                        print("📏 Distance from user: \(Int(distance))m")
                        
                        let newsItem = NewsItem(
                            id: UUID(),
                            title: article.title,
                            description: article.description ?? "",
                            url: article.url,
                            coordinates: coordinate,
                            publishedAt: article.publishedAt,
                            source: article.source.name,
                            distance: distance
                        )
                        
                        print("✅ Created news item: \(newsItem.title)")
                        return newsItem
                    }
                    
                    print("📊 Processed \(newNewsItems.count) valid news items from query: \(query)")
                    allNewsItems.append(contentsOf: newNewsItems)
                } catch {
                    print("❌ Decoding error for query \(query): \(error.localizedDescription)")
                }
            }.resume()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            print("📊 Processing all news items...")
            print("📰 Total new items fetched: \(allNewsItems.count)")
            print("💾 Total stored items: \(storedNews.count)")
            
            // Combine stored and new news, removing duplicates
            var combinedNews = storedNews + allNewsItems
            combinedNews = Array(Set(combinedNews))
            
            print("🔄 After deduplication: \(combinedNews.count) items")
            
            // Sort by date (newest first)
            combinedNews.sort { (item1: NewsItem, item2: NewsItem) -> Bool in
                if item1.distance == item2.distance {
                    return item1.publishedAt > item2.publishedAt
                }
                return item1.distance < item2.distance
            }
            
            print("📅 Sorted news items by distance and recency")
            
            // Keep only the most recent news items
            if combinedNews.count > self.maxStoredNews {
                combinedNews = Array(combinedNews.prefix(self.maxStoredNews))
                print("📝 Truncated to \(self.maxStoredNews) most recent items")
            }
            
            // Save the combined news
            self.saveNews(combinedNews)
            print("💾 Saved \(combinedNews.count) news items to storage")
            
            // Filter by location if user location is provided
            let filteredNews = userLocation != nil ? 
                self.filterNewsByLocation(combinedNews, userLocation: userLocation!) : 
                combinedNews
            
            print("📍 Filtered to \(filteredNews.count) items within range")
            print("📊 Final news items to display: \(filteredNews.count)")
            
            self.crimeNews = filteredNews
            completion(.success(filteredNews))
        }
    }
    
    private func extractLocationCoordinates(from text: String) -> CLLocationCoordinate2D? {
        // First try static lookup for common locations
        if let coordinate = staticLocationLookup(text: text) {
            return coordinate
        }
        
        // Only use NLP for location detection if we haven't hit rate limits
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        var foundLocation: String?
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if tag == .placeName {
                foundLocation = String(text[tokenRange])
                return false // stop at the first found location
            }
            return true
        }
        
        if let locationName = foundLocation {
            print("📍 Found place name: \(locationName)")
            // Use static lookup first for known locations
            if let coordinate = staticLocationLookup(text: locationName) {
                return coordinate
            }
            // Only attempt geocoding if static lookup fails
            return geocodeLocation(name: locationName)
        }
        
        return nil
    }
    
    private func staticLocationLookup(text: String) -> CLLocationCoordinate2D? {
        let locationKeywords: [(String, CLLocationCoordinate2D)] = [
            ("Delhi", CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090)),
            ("Mumbai", CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777)),
            ("Bangalore", CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)),
            ("Chennai", CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707)),
            ("Hyderabad", CLLocationCoordinate2D(latitude: 17.3850, longitude: 78.4867)),
            ("Pune", CLLocationCoordinate2D(latitude: 18.5204, longitude: 73.8567)),
            ("Jaipur", CLLocationCoordinate2D(latitude: 26.9124, longitude: 75.7873)),
            ("Lucknow", CLLocationCoordinate2D(latitude: 26.8467, longitude: 80.9462)),
            ("Bhopal", CLLocationCoordinate2D(latitude: 23.2599, longitude: 77.4126)),
            ("Koramangala", CLLocationCoordinate2D(latitude: 12.9279, longitude: 77.6271)),
            ("Indiranagar", CLLocationCoordinate2D(latitude: 12.9784, longitude: 77.6408)),
            ("MG Road", CLLocationCoordinate2D(latitude: 12.9759, longitude: 77.6074)),
            ("Whitefield", CLLocationCoordinate2D(latitude: 12.9698, longitude: 77.7500)),
            ("Electronic City", CLLocationCoordinate2D(latitude: 12.8399, longitude: 77.6770)),
            ("HSR Layout", CLLocationCoordinate2D(latitude: 12.9116, longitude: 77.6474)),
            ("BTM Layout", CLLocationCoordinate2D(latitude: 12.9166, longitude: 77.6101)),
            ("Jayanagar", CLLocationCoordinate2D(latitude: 12.9250, longitude: 77.5938)),
            ("JP Nagar", CLLocationCoordinate2D(latitude: 12.9077, longitude: 77.5851)),
            ("Malleswaram", CLLocationCoordinate2D(latitude: 13.0035, longitude: 77.5647))
        ]
        
        for (keyword, coordinate) in locationKeywords {
            if text.lowercased().contains(keyword.lowercased()) {
                return coordinate
            }
        }
        
        return nil
    }
    
    private func geocodeLocation(name: String) -> CLLocationCoordinate2D? {
        // Add a delay to prevent rate limiting
        Thread.sleep(forTimeInterval: 0.5)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = name + ", India"
        
        let search = MKLocalSearch(request: request)
        var coordinate: CLLocationCoordinate2D?
        
        let group = DispatchGroup()
        group.enter()
        
        search.start { response, error in
            if let error = error {
                print("❌ Geocoding error for \(name): \(error.localizedDescription)")
            } else if let item = response?.mapItems.first {
                coordinate = item.placemark.coordinate
            }
            group.leave()
        }
        
        _ = group.wait(timeout: .now() + 3.0)
        return coordinate
    }
    
    private func processNewsArticles(_ articles: [NewsArticle], userLocation: CLLocation) -> [NewsItem] {
        print("📰 Processing \(articles.count) news articles")
        var processedNews: [NewsItem] = []
        
        for article in articles {
            // Skip articles without coordinates
            guard let coordinates = extractCoordinates(from: article) else {
                print("⚠️ Skipping article without coordinates: \(article.title)")
                continue
            }
            
            // Calculate distance from user
            let articleLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let distance = userLocation.distance(from: articleLocation)
            
            // Only include articles within 50km radius
            if distance > 50000 {
                print("⚠️ Skipping article too far from user: \(article.title) (distance: \(distance)m)")
                continue
            }
            
            let newsItem = NewsItem(
                id: UUID(),  // Generate a new UUID for each news item
                title: article.title,
                description: article.description ?? "",
                url: article.url,
                coordinates: coordinates,
                publishedAt: article.publishedAt,
                source: article.source.name,
                distance: distance
            )
            
            processedNews.append(newsItem)
            print("✅ Added news item: \(newsItem.title) at \(coordinates.latitude), \(coordinates.longitude)")
        }
        
        // Sort by distance and recency
        processedNews.sort { (item1, item2) -> Bool in
            if item1.distance == item2.distance {
                return item1.publishedAt > item2.publishedAt
            }
            return item1.distance < item2.distance
        }
        
        print("📊 Processed \(processedNews.count) news items")
        return processedNews
    }
    
    private func extractCoordinates(from article: NewsArticle) -> CLLocationCoordinate2D? {
        // First try to extract from article content
        if let content = article.content {
            let coordinatePattern = #"(\d+\.\d+),\s*(\d+\.\d+)"#
            if let regex = try? NSRegularExpression(pattern: coordinatePattern),
               let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)) {
                let latitude = Double((content as NSString).substring(with: match.range(at: 1))) ?? 0
                let longitude = Double((content as NSString).substring(with: match.range(at: 2))) ?? 0
                if latitude != 0 && longitude != 0 {
                    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
            }
        }
        
        // If no coordinates in content, try to geocode the location from title/description
        let locationText = article.title + " " + (article.description ?? "")
        let locationPattern = #"(?:in|at|near)\s+([A-Za-z\s]+)(?:,\s*India)?"#
        if let regex = try? NSRegularExpression(pattern: locationPattern),
           let match = regex.firstMatch(in: locationText, range: NSRange(locationText.startIndex..., in: locationText)) {
            let locationName = (locationText as NSString).substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespaces)
            if let coordinates = cityCoordinates[locationName] {
                return coordinates
            }
        }
        
        return nil
    }
    
    private let cityCoordinates: [String: CLLocationCoordinate2D] = [
        "Bangalore": CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        "Delhi": CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),
        "Mumbai": CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777),
        "Chennai": CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707),
        "Kolkata": CLLocationCoordinate2D(latitude: 22.5726, longitude: 88.3639),
        "Pahalgam": CLLocationCoordinate2D(latitude: 34.0151, longitude: 75.3185),
        "Jammu": CLLocationCoordinate2D(latitude: 32.7266, longitude: 74.8570),
        "Kashmir": CLLocationCoordinate2D(latitude: 34.0837, longitude: 74.7973)
    ]
}

// Models for NewsAPI.org response
struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsArticle]
}

struct NewsArticle: Codable {
    let source: NewsSource
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct NewsSource: Codable {
    let id: String?
    let name: String
}

struct NewsItem: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let url: String
    let coordinates: CLLocationCoordinate2D
    let publishedAt: String
    let source: String
    let distance: CLLocationDistance
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(url)
        hasher.combine(publishedAt)
    }
    
    static func == (lhs: NewsItem, rhs: NewsItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.url == rhs.url &&
               lhs.publishedAt == rhs.publishedAt
    }
}

// Add Codable conformance for CLLocationCoordinate2D
extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let latitude = try container.decode(Double.self)
        let longitude = try container.decode(Double.self)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(latitude)
        try container.encode(longitude)
    }
} 